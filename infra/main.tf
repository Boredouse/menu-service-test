terraform {
  required_version = ">= 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  # Remote state. Key differs per env, passed at init:
  #   terraform init -backend-config="key=menu-dev.tfstate" ...
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

locals {
  prefix   = "ssp-menu-${var.environment_name}"
  tags = {
    service     = "menu-service"
    environment = var.environment_name
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# ---- Observability
resource "azurerm_log_analytics_workspace" "law" {
  name                = "log-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "appi-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.law.id
  application_type    = "web"
  tags                = local.tags
}

# ---- Registry (admin user off; access via managed identity + AcrPull)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = false
  tags                = local.tags
}

# ---- Key Vault (RBAC model, no access policies)
resource "azurerm_key_vault" "kv" {
  name                       = "kv-${local.prefix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = var.purge_protection
  tags                       = local.tags
}

# ---- App Service (Linux containers)
resource "azurerm_service_plan" "plan" {
  name                = "asp-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
  tags                = local.tags
}

resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true
  tags                = local.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = true
    health_check_path                       = "/health"
    ftps_state                              = "Disabled"
    minimum_tls_version                     = "1.2"
    container_registry_use_managed_identity = true

    application_stack {
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
      docker_image_name   = "ssp/menu-service:bootstrap" # placeholder, pipeline sets real tag
    }
  }

  app_settings = merge(
    {
      WEBSITES_PORT                         = "8080"
      WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.ai.connection_string
      SPRING_PROFILES_ACTIVE                = var.environment_name
    },
    # Key Vault references: app setting name => secret name in the vault.
    # App Service resolves these at runtime using its managed identity,
    # so the secret value never appears in Terraform, state, or the pipeline.
    {
      for setting, secret in var.secret_app_settings :
      setting => "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=${secret})"
    }
  )

  lifecycle {
    # Pipeline owns the image tag; don't let terraform revert it
    ignore_changes = [site_config[0].application_stack[0].docker_image_name]
  }
}

# Identity permissions
resource "azurerm_role_assignment" "app_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

resource "azurerm_role_assignment" "app_kv_secrets" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
}

# Log Analytics
resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "diag-${local.prefix}"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# Alert: >10 HTTP 5xx in 5 minutes (prod only)
resource "azurerm_monitor_action_group" "ops" {
  count               = var.enable_alerts ? 1 : 0
  name                = "ag-${local.prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "menu-ops"

  email_receiver {
    name          = "ops"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "http5xx" {
  count               = var.enable_alerts ? 1 : 0
  name                = "alert-${local.prefix}-http5xx"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.app.id]
  description         = "More than 10 HTTP 5xx responses in 5 minutes"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.ops[0].id
  }
}