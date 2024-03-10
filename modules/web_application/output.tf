output "app_service_default_site_hostname" {
  description = "The Default Hostname associated with the App Service."
  value       = azurerm_app_service.app_service.default_site_hostname
}
