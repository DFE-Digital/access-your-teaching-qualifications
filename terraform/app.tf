locals {
  aytq_env_vars = merge(try(local.infrastructure_secrets, null),
    {
      AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.evidence.name,
      AZURE_STORAGE_ACCESS_KEY   = azurerm_storage_account.evidence.primary_access_key,
      AZURE_STORAGE_CONTAINER    = azurerm_storage_container.uploads.name
      BIGQUERY_DATASET           = "events_${var.environment_name}",
      BIGQUERY_PROJECT_ID        = "teaching-qualifications",
      BIGQUERY_TABLE_NAME        = "events",
      CHECK_RECORDS_DOMAIN       = var.check_domain != null ? "https://${var.check_domain}" : "https://${local.aytq_web_app_name}.azurewebsites.net"
      ConnectionStrings__Redis   = azurerm_redis_cache.redis.primary_connection_string
      DATABASE_PASSWORD          = local.infrastructure_secrets.POSTGRES_ADMIN_PASSWORD
      DATABASE_URL               = "postgres://postgres@${local.postgres_server_name}.postgres.database.azure.com:5432"
      DOCKER_REGISTRY_SERVER_URL = "https://ghcr.io",
      HOSTING_DOMAIN             = var.domain != null ? "https://${var.domain}" : "https://${local.aytq_web_app_name}.azurewebsites.net"
      HOSTING_ENVIRONMENT_NAME   = local.hosting_environment
      RAILS_SERVE_STATIC_FILES   = "true"
      REDIS_URL                  = "rediss://:${azurerm_redis_cache.redis.primary_access_key}@${azurerm_redis_cache.redis.hostname}:${azurerm_redis_cache.redis.ssl_port}/0"
    }
  )
}

resource "azurerm_postgresql_flexible_server" "postgres-server" {
  name                   = local.postgres_server_name
  location               = data.azurerm_resource_group.group.location
  resource_group_name    = data.azurerm_resource_group.group.name
  version                = 14
  administrator_login    = local.infrastructure_secrets.POSTGRES_ADMIN_USERNAME
  administrator_password = local.infrastructure_secrets.POSTGRES_ADMIN_PASSWORD
  create_mode            = "Default"
  storage_mb             = var.postgres_flexible_server_storage_mb
  sku_name               = var.postgres_flexible_server_sku
  dynamic "high_availability" {
    for_each = var.enable_postgres_high_availability ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }
  lifecycle {
    ignore_changes = [
      tags,
      # Allow Azure to manage deployment zone. Ignore changes.
      zone,
      # Allow Azure to manage primary and standby server on fail-over. Ignore changes.
      high_availability[0].standby_availability_zone
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "postgres-database" {
  name      = local.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.postgres-server.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "postgres-fw-rule-azure" {
  name             = "AllowAzure"
  server_id        = azurerm_postgresql_flexible_server.postgres-server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_redis_cache" "redis" {
  name                = local.redis_database_name
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  capacity            = var.redis_service_capacity
  family              = var.redis_service_family
  sku_name            = var.redis_service_sku
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  redis_version       = var.redis_service_version
  redis_configuration {
    maxmemory_policy = "noeviction"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_service_plan" "service-plan" {
  name                   = local.app_service_plan_name
  location               = data.azurerm_resource_group.group.location
  resource_group_name    = data.azurerm_resource_group.group.name
  os_type                = "Linux"
  sku_name               = var.app_service_plan_sku
  zone_balancing_enabled = var.worker_count != null ? true : false
  worker_count           = var.worker_count
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_linux_web_app" "aytq-app" {
  name                = local.aytq_web_app_name
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  service_plan_id     = azurerm_service_plan.service-plan.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    http2_enabled       = true
    minimum_tls_version = "1.2"
    health_check_path   = "/health"
  }

  app_settings = local.aytq_env_vars

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_linux_web_app_slot" "aytq-stage" {
  count          = var.enable_blue_green ? 1 : 0
  name           = local.web_app_slot_name
  app_service_id = azurerm_linux_web_app.aytq-app.id
  site_config {
    http2_enabled       = true
    minimum_tls_version = "1.2"
    health_check_path   = "/health"
  }
  app_settings = local.aytq_env_vars
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_container_group" "aytq-worker" {
  name                = local.aytq_worker_group_name
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  os_type             = "Linux"
  ip_address_type     = "None"

  container {
    name  = local.aytq_worker_app_name
    image = var.aytq_docker_image

    cpu    = "0.5"
    memory = "0.5"

    environment_variables = local.aytq_env_vars

    commands = ["bundle", "exec", "sidekiq", "-C", "./config/sidekiq.yml"]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
