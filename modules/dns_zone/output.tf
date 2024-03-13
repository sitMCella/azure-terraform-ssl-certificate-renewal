output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = azurerm_resource_group.dns_zone_resource_group.name
}

output "dns_zone_name" {
  description = "The name of the Azure DNS Zone."
  value       = azurerm_dns_zone.dns_zone.name
}
