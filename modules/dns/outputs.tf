output "dns_zone_name" {
  value = azurerm_dns_zone.main.name
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.main.name_servers
}
