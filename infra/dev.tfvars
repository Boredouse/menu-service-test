subscription_id = "00000000-0000-0000-0000-000000000000" # dummy
environment_name = "dev"
acr_name = "sspmenudevacr"
resource_group_name = "rg-ssp-menu-dev"
web_app_name = "ssp-menu-service-dev"
app_service_plan_sku = "B1"
acr_sku = "Basic"
log_retention_days = 30
purge_protection = false
enable_alerts = false

secret_app_settings = {
  DB_PASSWORD = "db-password" # replace
}