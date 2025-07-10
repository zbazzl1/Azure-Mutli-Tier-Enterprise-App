provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstateenterpriseapp"
    container_name       = "terraform"
    key                  = "prod.terraform.tfstate"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment = "Production"
    Project     = "EnterpriseApp"
  }
}

module "key_vault" {
  source              = "./modules/key_vault"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  key_vault_name      = var.key_vault_name
  principal_id        = var.principal_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  tags                = azurerm_resource_group.main.tags
}

# Modules
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  tags                = azurerm_resource_group.main.tags
}

module "dns" {
  source                = "./modules/dns"
  resource_group_name   = azurerm_resource_group.main.name
  dns_zone_name         = var.dns_zone_name
  dns_records           = var.dns_records
  app_gateway_public_ip = module.networking.app_gateway_public_ip
  tags                  = azurerm_resource_group.main.tags
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  web_subnet_id       = module.networking.web_subnet_id
  app_subnet_id       = module.networking.app_subnet_id
  admin_username      = data.azurerm_key_vault_secret.admin_username.value
  admin_password      = data.azurerm_key_vault_secret.admin_password.value
  tags                = azurerm_resource_group.main.tags
  depends_on          = [module.key_vault]
}

module "database" {
  source              = "./modules/database"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  db_subnet_id        = module.networking.db_subnet_id
  tags                = azurerm_resource_group.main.tags
  admin_username      = data.azurerm_key_vault_secret.admin_username.value
  admin_password      = data.azurerm_key_vault_secret.admin_password.value
  depends_on          = [module.key_vault]
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = azurerm_resource_group.main.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vmss_web_id         = module.compute.web_vmss_id
  vmss_app_id         = module.compute.app_vmss_id
  app_gateway_id      = module.networking.app_gateway_id
  sql_instance_id     = module.database.sql_instance_id
  tags                = azurerm_resource_group.main.tags
}

data "azurerm_key_vault_secret" "admin_username" {
  name         = "admin-username"
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
}

data "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  key_vault_id = module.key_vault.key_vault_id
  depends_on   = [module.key_vault]
}
