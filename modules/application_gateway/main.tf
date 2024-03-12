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
  tags                            = var.tags
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
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

data "azurerm_key_vault_certificate" "key_vault_certificate" {
  name         = "sslcert"
  key_vault_id = azurerm_key_vault.key_vault.id
  version      = "latest"
}

// 4. Provision the Application Gateway after the initial SSL certificate has been added to the Key Vault 
// using the function in the Azure Function App.
resource "azurerm_application_gateway" "application_gateway" {
  name                = "agw-web-application-prod-${var.location}-001"
  resource_group_name = azurerm_resource_group.application_gateway_resource_group.name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "application-gateway-ip-configuration"
    subnet_id = var.application_gateway_subnet_id
  }

  frontend_port {
    name = "https-frontend-port"
    port = 443
  }

  frontend_port {
    name = "http-frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "public-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.application_gateway_public_ip.id
  }

  backend_address_pool {
    name  = "backend-address-pool-web-application"
    fqdns = [var.app_service_default_site_hostname]
  }

  backend_address_pool {
    name  = "backend-address-pool-storage-account"
    fqdns = [var.storage_account_primary_web_host]
  }

  backend_http_settings {
    name                                = "backend-http-settings"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    probe_name                          = "probe-web-application"
    pick_host_name_from_backend_address = true
  }

  backend_http_settings {
    name                                = "backend-https-settings"
    cookie_based_affinity               = "Disabled"
    path                                = "/"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    probe_name                          = "probe-storage-account"
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "public-frontend-ip-configuration"
    frontend_port_name             = "https-frontend-port"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl_certificate"
    host_name                      = var.host_name
    require_sni                    = true
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "public-frontend-ip-configuration"
    frontend_port_name             = "http-frontend-port"
    protocol                       = "Http"
    host_name                      = var.host_name
    require_sni                    = false
  }

  request_routing_rule {
    name                       = "web-application-route"
    priority                   = 10
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "backend-address-pool-web-application"
    backend_http_settings_name = "backend-http-settings"
  }

  request_routing_rule {
    name                       = "storage-account-route"
    priority                   = 20
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool-storage-account"
    backend_http_settings_name = "backend-https-settings"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.application_gateway_user_assigned_identity.id]
  }

  probe {
    name                                      = "probe-web-application"
    host                                      = var.app_service_default_site_hostname
    interval                                  = 10
    protocol                                  = "Http"
    path                                      = "/"
    timeout                                   = 5
    unhealthy_threshold                       = 5
    pick_host_name_from_backend_http_settings = false
  }

  probe {
    name                                      = "probe-storage-account"
    host                                      = var.storage_account_primary_web_host
    interval                                  = 10
    protocol                                  = "Https"
    path                                      = "/"
    timeout                                   = 5
    unhealthy_threshold                       = 5
    pick_host_name_from_backend_http_settings = false
    match {
      status_code = ["200-499"]
    }
  }

  ssl_certificate {
    name                = "ssl_certificate"
    key_vault_secret_id = data.azurerm_key_vault_certificate.key_vault_certificate.secret_id
  }

  tags = var.tags
}

// 5. Create the final record in the Azure DNS Zone.
// Delete the temporary record from the Azure DNS Zone.
resource "azurerm_dns_a_record" "web_application_dns_zone_record" {
  name                = var.web_application_subdomain_name
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name
  ttl                 = 3600
  records             = [azurerm_public_ip.application_gateway_public_ip.ip_address]
}
