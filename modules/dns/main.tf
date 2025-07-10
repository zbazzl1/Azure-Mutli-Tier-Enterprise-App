resource "azurerm_dns_zone" "main" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_dns_a_record" "records" {
  for_each            = var.dns_records
  name                = each.key
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = [var.app_gateway_public_ip]
  tags                = var.tags
  depends_on          = [azurerm_dns_zone.main]
}
