resource "azurerm_mssql_managed_instance" "main" {
  name                         = "sql-managed-instance"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  sku_name                     = "GP_Gen5"
  storage_size_in_gb           = 256
  vcores                       = 8
  subnet_id                    = var.db_subnet_id
  license_type                 = "LicenseIncluded"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  tags                         = var.tags
}

resource "azurerm_private_endpoint" "sql_endpoint" {
  name                = "sql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.db_subnet_id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_managed_instance.main.id
    subresource_names              = ["managedInstance"]
    is_manual_connection           = false
  }

  tags = var.tags
}
