locals {
  web_application_domain_name    = "app.${var.domain_name}"
  web_application_subdomain_name = "app"
  ssl_certificate_name           = "sslcert"
  tags                           = {}
}

module "network" {
  source = "./modules/network"

  location                                    = var.location
  virtual_network_address_space               = ["10.0.0.0/24"]
  application_gateway_subnet_address_prefixes = ["10.0.0.0/27"]
  tags                                        = local.tags
}

module "dns_zone" {
  source = "./modules/dns_zone"

  location    = var.location
  domain_name = var.domain_name
  tags        = local.tags
}

module "web_application" {
  source = "./modules/web_application"

  location        = var.location
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tags            = local.tags
}

module "ssl_certificate" {
  source = "./modules/ssl_certificate"

  location              = var.location
  location_abbreviation = var.location_abbreviation
  host_name             = local.web_application_domain_name
  tags                  = local.tags
}

module "ssl_certificate_renewal" {
  source = "./modules/ssl_certificate_renewal"

  location                              = var.location
  location_abbreviation                 = var.location_abbreviation
  resource_group_name                   = module.ssl_certificate.resource_group_name
  resource_group_id                     = module.ssl_certificate.resource_group_id
  dns_zone_resource_group_name          = module.dns_zone.resource_group_name
  dns_zone_name                         = module.dns_zone.dns_zone_name
  storage_account_name                  = module.ssl_certificate.storage_account_name
  storage_account_primary_web_host      = module.ssl_certificate.storage_account_primary_web_host
  web_application_subdomain_name        = local.web_application_subdomain_name
  key_vault_id                          = module.application_gateway.key_vault_id
  key_vault_name                        = module.application_gateway.key_vault_name
  application_gateway_resource_group_id = module.application_gateway.resource_group_id
  host_name                             = local.web_application_domain_name
  key_name                              = local.ssl_certificate_name
  email_address                         = var.email_address
  pfx_password                          = var.pfx_password
  subscription_id                       = var.subscription_id
  tenant_id                             = var.tenant_id
  client_id                             = var.client_id
  client_secret                         = var.client_secret
  tags                                  = local.tags
}

module "application_gateway" {
  source = "./modules/application_gateway"

  location                          = var.location
  location_abbreviation             = var.location_abbreviation
  tenant_id                         = var.tenant_id
  application_gateway_subnet_id     = module.network.application_gateway_subnet_id
  app_service_default_site_hostname = module.web_application.app_service_default_site_hostname
  host_name                         = local.web_application_domain_name
  storage_account_primary_web_host  = module.ssl_certificate.storage_account_primary_web_host
  dns_zone_resource_group_name      = module.dns_zone.resource_group_name
  dns_zone_name                     = module.dns_zone.dns_zone_name
  web_application_subdomain_name    = local.web_application_subdomain_name
  tags                              = local.tags
}
