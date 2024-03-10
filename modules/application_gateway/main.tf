resource "azurerm_resource_group" "application_gateway_resource_group" {
  name     = "rg-application-gateway-prod-${var.location}-001"
  location = var.location
  tags     = var.tags
}

resource "azurerm_key_vault" "key_vault" {
  name                            = "kvappgtwprod${var.location_abbreviation}001"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.application_gateway_resource_group.name
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  tenant_id                       = var.tenant_id
  public_network_access_enabled   = true
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  sku_name                        = "standard"
}

resource "azurerm_user_assigned_identity" "application_gateway_user_assigned_identity" {
  name                = "id-application-gateway-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.application_gateway_resource_group.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "application_gateway_identity_role_assignment" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.application_gateway_user_assigned_identity.principal_id
}

resource "azurerm_public_ip" "application_gateway_public_ip" {
  name                = "ip-application-gateway-prod-${var.location}-001"
  resource_group_name = azurerm_resource_group.application_gateway_resource_group.name
  location            = var.location
  allocation_method   = "Dynamic"
}
