variable "environment_name" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "app_suffix" {
  type    = string
  default = ""
}

variable "azure_sp_credentials_json" {
  type    = string
  default = null
}

variable "app_service_plan_sku" {
  type    = string
  default = "B1"
}

variable "postgres_flexible_server_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "postgres_flexible_server_storage_mb" {
  type    = number
  default = 32768
}

variable "enable_postgres_high_availability" {
  type    = bool
  default = false
}
variable "key_vault_name" {
  type = string
}

variable "key_vault_resource_group" {
  description = "Only required for review apps which use the dev KeyVault"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_tags" {
  description = "Only required for review apps which are deployed into their own, tempoarary, resource group"
  type        = string
  default     = ""
}

variable "redis_service_sku" {
  type    = string
  default = "Basic"
}

variable "redis_service_version" {
  type    = number
  default = 6
}

variable "redis_service_family" {
  type    = string
  default = "C"
}

variable "redis_service_capacity" {
  type    = number
  default = 1
}

variable "keyvault_logging_enabled" {
  type    = bool
  default = false
}

variable "storage_diagnostics_logging_enabled" {
  type    = bool
  default = false
}

variable "storage_log_categories" {
  type    = list(string)
  default = []
}

variable "log_analytics_sku" {
  type    = string
  default = "PerGB2018"
}

variable "enable_blue_green" {
  type    = bool
  default = false
}

variable "worker_count" {
  description = "It should be set to a multiple of the number of availability zones in the region"
  type        = number
  default     = null
}

variable "statuscake_alerts" {
  type    = map(any)
  default = {}
}

variable "domain" {
  default     = null
  description = "The domain at which the AYTQ service can be accessed"
}

variable "check_domain" {
  default     = null
  description = "The domain at which the Check service can be accessed"
}

variable "region_name" {
  default = "west europe"
  type    = string
}

variable "create_env_resource_group" {
  default = false
  type    = bool
}

variable "statuscake_contact_groups" {
  type        = list(string)
  default     = []
  description = "IDs of the StatusCake contact groups"
}

variable "statuscake_ssl_domains" {
  type        = list(string)
  default     = []
  description = "Domains/urls for statuscake ssl check. If empty, SSL check is not enabled"
}

variable "aytq_docker_image" {
  type = string
}

variable "evidence_container_retention_in_days" {
  default = 7
  type = number
}

variable "evidence_storage_account_name" {
  default = null
}

variable "region_name" {
  default = "west europe"
  type = "string"
}

locals {
  hosting_environment          = var.environment_name
  aytq_web_app_name            = "${var.resource_prefix}-${var.environment_name}${var.app_suffix}-app"
  aytq_worker_app_name         = "${var.resource_prefix}-${var.environment_name}${var.app_suffix}-wkr-aci"
  aytq_worker_group_name       = "${var.resource_prefix}-${var.environment_name}${var.app_suffix}-wkr-cg"
  postgres_server_name         = "${var.resource_prefix}-${var.environment_name}${var.app_suffix}-psql"
  postgres_database_name       = "access_your_teaching_qualifications_production"
  redis_database_name          = "${var.resource_prefix}-${var.environment_name}${var.app_suffix}-redis"
  app_insights_name            = "${var.resource_prefix}-${var.environment_name}${var.app_suffix}-appi"
  log_analytics_workspace_name = "${var.resource_prefix}-${var.environment_name}-log"
  app_service_plan_name        = "${var.resource_prefix}-${var.environment_name}-plan"

  keyvault_logging_enabled            = var.keyvault_logging_enabled
  storage_diagnostics_logging_enabled = length(var.storage_log_categories) > 0
  storage_log_categories              = var.storage_log_categories
  storage_log_retention_days          = var.environment_name == "prd" ? 365 : 30
  web_app_slot_name                   = "staging"
}
