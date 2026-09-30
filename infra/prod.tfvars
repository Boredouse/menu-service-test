subscription_id      = "00000000-0000-0000-0000-000000000000" # replace
environment_name     = "prod"
acr_name             = "sspmenuprodacr"
resource_group_name  = "rg-ssp-menu-prod"
web_app_name         = "ssp-menu-service-prod"
app_service_plan_sku = "S1"
acr_sku              = "Standard"
log_retention_days   = 90
purge_protection     = true
enable_alerts        = true
alert_email          = "menu-ops@example.com" # replace

secret_app_settings = {
  DB_PASSWORD = "db-password" # replace
}