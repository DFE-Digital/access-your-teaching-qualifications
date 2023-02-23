resource "azurerm_log_analytics_workspace" "analytics" {
  name                = local.log_analytics_workspace_name
  location            = data.azurerm_resource_group.group.location
  resource_group_name = data.azurerm_resource_group.group.name
  sku                 = var.log_analytics_sku
  retention_in_days   = local.storage_log_retention_days

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "aytq-keyvault-diagnostics" {
  count                      = local.keyvault_logging_enabled ? 1 : 0
  name                       = "${data.azurerm_key_vault.vault.name}-diagnostics"
  target_resource_id         = data.azurerm_key_vault.vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.analytics.id

  log {
    category = "AuditEvent"
    enabled  = true #at least one Audit/Metric needs to be enabled.

    retention_policy {
      enabled = local.keyvault_logging_enabled
    }
  }


  metric {
    category = "AllMetrics"
    enabled  = local.keyvault_logging_enabled
    retention_policy {
      enabled = local.keyvault_logging_enabled
    }
  }
}
