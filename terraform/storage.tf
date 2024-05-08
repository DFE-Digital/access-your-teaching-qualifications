resource "azurerm_storage_account" "evidence" {
  name                              = var.evidence_storage_account_name
  resource_group_name               = var.resource_group_name
  location                          = var.region_name
  account_replication_type          = var.environment_name != "production" ? "LRS" : "GRS"
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false

  blob_properties {
    last_access_time_enabled = true

    container_delete_retention_policy {
      days = var.evidence_container_retention_in_days
    }
  }

  depends_on = [data.azurerm_resource_group.group]
}


resource "azurerm_storage_encryption_scope" "evidence-encryption" {
  name               = "microsoftmanaged"
  storage_account_id = azurerm_storage_account.evidence.id
  source             = "Microsoft.Storage"
}


resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.evidence.name
  container_access_type = "private"
}
