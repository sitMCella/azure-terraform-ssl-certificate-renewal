resource "azurerm_resource_group" "ssl_certificate_renewal_resource_group" {
  name     = "rg-ssl-certificate-renewal-prod-${var.location}-001"
  location = var.location
  tags     = var.tags
}

// Configure the nameservers of the registered domain in the registrar portal with the nameservers defined by the Azure DNS Zone (Record name @, type NS).
resource "azurerm_dns_zone" "dns_zone" {
  name                = var.domain_name
  resource_group_name = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  tags                = var.tags
}

resource "azurerm_storage_account" "storage_account" {
  name                          = "stsslcertprod${var.location_abbreviation}002"
  resource_group_name           = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  location                      = var.location
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  access_tier                   = "Hot"
  enable_https_traffic_only     = false
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  public_network_access_enabled = true
  static_website {
  }
  // Configure the custom domain after the temporary record has been added in the Azure DNS Zone.
  custom_domain {
    name          = var.host_name
    use_subdomain = false
  }
  blob_properties {
    delete_retention_policy {
      days = 14
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  tags = var.tags
}