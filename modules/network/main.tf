resource "azurerm_resource_group" "network_resource_group" {
  name     = "rg-network-prod-${var.location}-001"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "vnet-network-prod-${var.location}-001"
  resource_group_name = azurerm_resource_group.network_resource_group.name
  location            = var.location
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "application_gateway_subnet" {
  name                 = "snet-application-gateway-prod-${var.location}-001"
  resource_group_name  = azurerm_resource_group.network_resource_group.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = var.application_gateway_subnet_address_prefixes
}
