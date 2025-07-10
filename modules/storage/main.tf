resource "azurerm_storage_account" "main" {
  name                     = "stenterpriseapp"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_backup_policy_vm" "main" {
  name                = "vm-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

resource "azurerm_recovery_services_vault" "main" {
  name                = "backup-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = var.tags
}
