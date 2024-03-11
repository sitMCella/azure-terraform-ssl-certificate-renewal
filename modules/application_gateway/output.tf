output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.key_vault.name
}

output "resource_group_id" {
  description = "The ID of the Resource Group."
  value       = azurerm_resource_group.application_gateway_resource_group.id
}
