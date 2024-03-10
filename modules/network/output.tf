output "application_gateway_subnet_id" {
  description = "The ID of the Application Gatway subnet."
  value       = azurerm_subnet.application_gateway_subnet.id
}
