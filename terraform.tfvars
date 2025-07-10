resource_group_name = "rg-enterprise-app"
location            = "West Europe"
vnet_name           = "vnet-enterprise-app"
vnet_address_space  = ["10.0.0.0/16"]
subnets = {
  web                = { address_prefix = "10.0.1.0/24" }
  app                = { address_prefix = "10.0.2.0/24" }
  db                 = { address_prefix = "10.0.3.0/24" }
  mgmt               = { address_prefix = "10.0.4.0/24" }
  AzureBastionSubnet = { address_prefix = "10.0.5.0/24" }
}
dns_zone_name = "example341073.com"
dns_records = {
  app = { ttl = 300 }
}
admin_username = "adminuser"
admin_password = "password"
key_vault_name = "kv-enterprise-app"
principal_id   = "<your-principal-id>" # Replace with your actual principal ID
