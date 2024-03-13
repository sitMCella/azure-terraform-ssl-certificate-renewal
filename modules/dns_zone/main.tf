resource "azurerm_resource_group" "dns_zone_resource_group" {
  name     = "rg-dns-zone-prod-${var.location}-001"
  location = var.location
  tags     = var.tags
}

// 1. Configure the nameservers of the registered domain in the registrar portal with the nameservers defined by the Azure DNS Zone (Record name @, type NS).
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.dns_zone_resource_group.name
  tags                = var.tags
}
