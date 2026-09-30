variable "subscription_id" {
  type = string
}

variable "environment_name" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment_name)
    error_message = "environment_name must be dev or prod."
  }
}

variable "location" {
  type    = string
  default = "uksouth"
}

variable "app_service_plan_sku" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "log_retention_days" {
  type = number
}

variable "purge_protection" {
  type = bool
}

variable "enable_alerts" {
  type = bool
}

variable "alert_email" {
  type    = string
  default = ""
}

variable "acr_name" {
  type        = string
  description = "Globally unique, alphanumeric only. Must match acrName in azure-pipelines.yml."
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "acr_name must be 5-50 alphanumeric characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Must match rg variable in azure-pipelines.yml."
}

variable "web_app_name" {
  type        = string
  description = "Globally unique. Must match app variable in azure-pipelines.yml."
}

variable "secret_app_settings" {
  type        = map(string)
  description = "App setting name => Key Vault secret name. Secret must exist in the vault."
  default     = {}
}