variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-enterprise-app"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-enterprise-app"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets with name and address prefix"
  type = map(object({
    address_prefix = string
  }))
  default = {
    web                = { address_prefix = "10.0.1.0/24" }
    app                = { address_prefix = "10.0.2.0/24" }
    db                 = { address_prefix = "10.0.3.0/24" }
    mgmt               = { address_prefix = "10.0.4.0/24" }
    AzureBastionSubnet = { address_prefix = "10.0.5.0/24" }
  }
}

variable "admin_username" {
  description = "Administrator username for VMs and SQL managed Instance. Defined in HCP Terraform as Tf variables."
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator username for VMs and SQL managed Instance. Defined in HCP Terraform as Tf variables."
  type        = string
  sensitive   = true
}

variable "dns_zone_name" {
  description = "Name of the Azure DNS Zone (e.g., example.com)"
  type        = string
  default     = null
}

variable "dns_records" {
  description = "Map of DNS A records to create (e.g., { subdomain = ttl })"
  type = map(object({
    ttl = number
  }))
  default = {}
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "kv-enterprise-app"
}

variable "principal_id" {
  description = "Principal ID of the user or service principal for Key Vault access"
  type        = string
}
