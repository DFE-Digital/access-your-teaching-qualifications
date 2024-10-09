variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}
variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "environment" {
  description = "Name of the deployed environment in AKS"
}
variable "azure_resource_prefix" {
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}
variable "config" {
  description = "Long name of the environment configuration, e.g. review, development, production..."
}
variable "config_short" {
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}
variable "service_name" {
  description = "Full name of the service. Lowercase and hyphen separated"
}
variable "service_short" {
  description = "Short name to identify the service. Up to 6 charcters."
}
variable "deploy_azure_backing_services" {
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}
variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}
variable "enable_postgres_backup_storage" {
  default     = false
  description = "Create a storage account to store database dumps"
}
variable "docker_image" {
  description = "Docker image full name to identify it in the registry. Includes docker registry, repository and tag e.g.: ghcr.io/dfe-digital/teacher-pay-calculator:673f6309fd0c907014f44d6732496ecd92a2bcd0"
}
variable "resource_group_name" {
  description = "Resource group name where the service resources are deployed: databases, storage accounts..."
}
variable "external_url" {
  default     = null
  description = "Healthcheck URL for StatusCake monitoring"
}
variable "statuscake_contact_groups" {
  default     = []
  description = "ID of the contact group in statuscake web UI"
}
variable "statuscake_alerts" {
  type = object({
    website_url    = optional(list(string), [])
    ssl_url        = optional(list(string), [])
    contact_groups = optional(list(number), [])
  })
  default = {}
}
variable "enable_monitoring" {
  default     = false
  description = "Enable monitoring and alerting"
}
variable "send_traffic_to_maintenance_page" {
  default     = false
  description = "During a maintenance operation, keep sending traffic to the maintenance page instead of resetting the ingress"
}

variable "account_replication_type" {
  description = "Replication LRS (across AZs) or GRS (across regions)"
  default     = "LRS"
}
variable "evidence_container_retention_in_days" {
  description = "For how long can the container be recovered if it's deleted"
  default     = 7
  type        = number
}
variable "postgres_flexible_server_sku" {
  default = "B_Standard_B1ms"
}
variable "app_replicas" {
  description = "number of replicas of the web app"
  default     = 1
}
variable "worker_replicas" {
  description = "number of replicas of the workers"
  default     = 1
}
variable "postgres_enable_high_availability" {
  default = false
}

locals {
  postgres_ssl_mode = var.enable_postgres_ssl ? "require" : "disable"

  environment_variables = yamldecode(file("${path.module}/config/${var.config}.yml"))

  check_service_name     = "check-a-teachers-record"
  check_domain           = "${local.check_service_name}-${var.environment}.${module.cluster_data.ingress_domain}"
  check_external_domain  = try(local.environment_variables["CHECK_EXTERNAL_DOMAIN"], local.check_domain)
  access_domain          = "${var.service_name}-${var.environment}.${module.cluster_data.ingress_domain}"
  access_external_domain = try(local.environment_variables["ACCESS_EXTERNAL_DOMAIN"], local.access_domain)

  azure_resource_prefix_short = substr(var.azure_resource_prefix, 0, 5)
  # If there are multiple environments per config (as in review apps), we need the environment name, but no hyphens
  # s189paytqevidpdsa vs s189daytqevidpr12345sa
  storage_account_environment   = var.config == var.environment ? var.config_short : replace(var.environment, "-", "")
  evidence_storage_account_name = "${local.azure_resource_prefix_short}aytqevid${local.storage_account_environment}sa"
}
