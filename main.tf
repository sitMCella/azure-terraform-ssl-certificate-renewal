resource "azurerm_resource_group" "network_resource_group" {
  name     = "rg-network-prod-${var.location}-001"
  location = var.location
}

