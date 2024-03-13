output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
}

output "resource_group_id" {
  description = "The ID of the Resource Group."
  value       = azurerm_resource_group.ssl_certificate_renewal_resource_group.id
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.storage_account.name
}

output "storage_account_primary_web_host" {
  description = "The primary web host of the Storage Account static web app."
  value       = azurerm_storage_account.storage_account.primary_web_host
}
