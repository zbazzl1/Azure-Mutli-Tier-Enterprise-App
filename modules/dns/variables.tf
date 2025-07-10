variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }

variable "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  type        = string
}

variable "dns_zone_name" {
  description = "Name of DNS zone"
  type        = string
}

variable "dns_records" {
  description = "Map of DNS records to create"
  type = map(object({
    ttl = number
  }))
}
