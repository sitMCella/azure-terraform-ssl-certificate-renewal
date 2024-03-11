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

// Temporary record to insert in the Azure DNS Zone in order to generate the initial SSL Certificate.
// This record have to be removed afterwards.
resource "azurerm_dns_cname_record" "web_application_dns_zone_record" {
  name                = "app"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  ttl                 = 10
  record              = azurerm_storage_account.storage_account.primary_web_host
}

resource "azurerm_storage_account" "storage_account_function_app" {
  name                          = "stfuncprod${var.location_abbreviation}001"
  resource_group_name           = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  location                      = var.location
  account_tier                  = "Standard"
  account_kind                  = "StorageV2"
  account_replication_type      = "LRS"
  access_tier                   = "Hot"
  enable_https_traffic_only     = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  public_network_access_enabled = true
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

resource "azurerm_user_assigned_identity" "function_app_user_assigned_identity" {
  name                = "id-function-app-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "function_app_identity_role_assignment" {
  scope                = azurerm_storage_account.storage_account_function_app.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.function_app_user_assigned_identity.principal_id
}

resource "azurerm_role_assignment" "function_app_identity_role_assignment_003" {
  scope                = azurerm_resource_group.ssl_certificate_renewal_resource_group.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.function_app_user_assigned_identity.principal_id
}

resource "azurerm_role_assignment" "function_app_identity_role_assignment_002" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.function_app_user_assigned_identity.principal_id
}

resource "azurerm_role_assignment" "function_app_identity_role_assignment_004" {
  scope                = var.application_gateway_resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.function_app_user_assigned_identity.principal_id
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-function-app-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  os_type             = "Windows"
  sku_name            = "Y1"
  tags                = var.tags
}

data "archive_file" "function_package" {
  type        = "zip"
  source_dir  = "${path.cwd}/modules/ssl_certificate_renewal/function"
  output_path = "function.zip"
}

resource "random_string" "random_function_app_name" {
  length  = 7
  special = false
  upper   = false
}

resource "azurerm_application_insights" "function_app_application_insights" {
  name                = "appi-function-app-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  application_type    = "other"
}

resource "azurerm_windows_function_app" "function_app" {
  name                       = "func-${random_string.random_function_app_name.result}-prod-${var.location}-001"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
  service_plan_id            = azurerm_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.storage_account_function_app.name
  storage_account_access_key = azurerm_storage_account.storage_account_function_app.primary_access_key
  site_config {
    always_on = false
    application_stack {
      powershell_core_version = "7.2"
    }
    application_insights_connection_string = azurerm_application_insights.function_app_application_insights.connection_string
    application_insights_key               = azurerm_application_insights.function_app_application_insights.instrumentation_key
  }
  app_settings = {
    Domain                   = var.host_name
    EmailAddress             = var.email_address
    KeyVaultName             = var.key_vault_name
    KeyName                  = var.key_name
    PfxPassword              = var.pfx_password
    StorageName              = azurerm_storage_account.storage_account.name
    StorageResourceGroupName = azurerm_resource_group.ssl_certificate_renewal_resource_group.name
    SubscriptionId           = var.subscription_id
    TenantId                 = var.tenant_id
    ApplicationId            = var.client_id
    ClientSecret             = var.client_secret
  }
  zip_deploy_file = data.archive_file.function_package.output_path
  tags            = var.tags
}
