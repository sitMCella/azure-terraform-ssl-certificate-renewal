locals {
  tags = {}
}

module "network" {
  source = "./modules/network"

  location                                    = var.location
  virtual_network_address_space               = ["10.0.0.0/24"]
  application_gateway_subnet_address_prefixes = ["10.0.0.0/27"]
  tags                                        = local.tags
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

module "application_gateway" {
  source = "./modules/application_gateway"

  location                          = var.location
  location_abbreviation             = var.location_abbreviation
  tenant_id                         = var.tenant_id
  application_gateway_subnet_id     = module.network.application_gateway_subnet_id
  app_service_default_site_hostname = module.web_application.app_service_default_site_hostname
  host_name                         = "app.${var.domain_name}"
  tags                              = local.tags
}
