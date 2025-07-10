output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "app_gateway_public_ip" {
  description = "Public IP of the Application Gateway"
  value       = module.networking.app_gateway_public_ip
}

output "dns_zone_name" {
  description = "Name of the DNS Zone"
  value       = module.dns.dns_zone_name
}

output "dns_zone_name_servers" {
  description = "Name servers for the DNS Zone"
  value       = module.dns.dns_zone_name_servers
}
