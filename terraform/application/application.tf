module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace              = var.namespace
  environment            = var.environment
  azure_resource_prefix  = var.azure_resource_prefix
  service_short          = var.service_short
  config_short           = var.config_short
  secret_key_vault_short = "app"

  is_rails_application = true

  config_variables = {
    HOSTING_ENVIRONMENT_NAME   = var.config
    PGSSLMODE                  = local.postgres_ssl_mode
    HOSTING_DOMAIN             = "https://${local.access_external_domain}"
    CHECK_RECORDS_DOMAIN       = "https://${local.check_external_domain}"
    DFE_SIGN_IN_REDIRECT_URL   = "https://${local.check_external_domain}/check-records/auth/dfe/callback"
    AZURE_STORAGE_ACCOUNT_NAME = local.evidence_storage_account_name
    AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name
    BIGQUERY_DATASET           = "events_${var.config}"
    BIGQUERY_PROJECT_ID        = "teaching-qualifications"
    BIGQUERY_TABLE_NAME        = "events"
    RAILS_SERVE_STATIC_FILES   = "true"
  }
  secret_variables = merge({
    DATABASE_URL             = module.postgres.url
    REDIS_URL                = module.redis-cache.url
    AZURE_STORAGE_ACCESS_KEY = azurerm_storage_account.evidence.primary_access_key
  }, local.federated_auth_secrets)
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name
  probe_path   = "/health"

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  replicas     = var.app_replicas
  docker_image = var.docker_image
  enable_logit = true

  send_traffic_to_maintenance_page = var.send_traffic_to_maintenance_page

  web_external_hostnames = [local.check_domain]

  ingress_annotations = {
    "nginx.ingress.kubernetes.io/rate-limit-rps"        = var.environment == "production" ? "50" : "100"
    "nginx.ingress.kubernetes.io/rate-limit-connections" = var.environment == "production" ? "20" : "30"
  }
}

module "worker_application" {
  source = "./vendor/modules/aks//aks/application"

  name    = "worker"
  is_web  = false
  command = ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml"]

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  replicas                   = var.worker_replicas
  docker_image               = var.docker_image
  enable_logit               = true
  enable_gcp_wif             = var.enable_dfe_analytics_federated_auth
}
