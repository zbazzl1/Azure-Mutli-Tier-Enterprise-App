output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "web_subnet_id" {
  value = azurerm_subnet.subnets["web"].id
}

output "app_subnet_id" {
  value = azurerm_subnet.subnets["app"].id
}

output "db_subnet_id" {
  value = azurerm_subnet.subnets["db"].id
}

output "app_gateway_id" {
  value = azurerm_application_gateway.main.id
}

output "app_gateway_public_ip" {
  value = azurerm_public_ip.app_gateway.ip_address
}
