resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
  ddos_protection_plan {
    enable = true
    id     = azurerm_network_ddos_protection_plan.main.id
  }
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-app-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "main" {
  name                = "app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "app-gateway-ip-config"
    subnet_id = azurerm_subnet.subnets["web"].id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "app-gateway-frontend-ip"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name = "web-backend"
  }

  backend_address_pool {
    name = "app-backend"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "app-gateway-frontend-ip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "web-backend"
    backend_http_settings_name = "http-settings"
    url_path_map_name          = "url-path-map"
    priority                   = 100
  }

  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = "web-backend"
    default_backend_http_settings_name = "http-settings"
    path_rule {
      name                       = "api"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "app-backend"
      backend_http_settings_name = "http-settings"
    }
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-HTTP-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80,443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-Web-to-App"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnets["web"].address_prefix
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-App-to-DB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.subnets["app"].address_prefix
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "mgmt_nsg" {
  name                = "mgmt-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389,22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnets["web"].id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnets["app"].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnets["db"].id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "mgmt_nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnets["mgmt"].id
  network_security_group_id = azurerm_network_security_group.mgmt_nsg.id
}

resource "azurerm_bastion_host" "main" {
  name                = "bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_ddos_protection_plan" "main" {
  name                = "ddos-protection"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
