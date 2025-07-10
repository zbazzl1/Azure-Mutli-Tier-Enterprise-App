variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "subnets" { type = map(object({ address_prefix = string })) }
variable "tags" { type = map(string) }

variable "dns_zone_name" {
  description = "Name of DNS zone"
  type        = string
  default     = null
}

