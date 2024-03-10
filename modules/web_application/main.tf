resource "azurerm_resource_group" "web_application_resource_group" {
  name     = "rg-web-application-prod-${var.location}-001"
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "container_registry" {
  name                          = "crwebapplicationprod${var.location}001"
  resource_group_name           = azurerm_resource_group.web_application_resource_group.name
  location                      = var.location
  sku                           = "Standard"
  admin_enabled                 = true
  public_network_access_enabled = true
  zone_redundancy_enabled       = false
  tags                          = var.tags
}

resource "null_resource" "docker_image" {
  triggers = {
    image_name         = "${azurerm_container_registry.container_registry.login_server}/samples/dotnet"
    image_tag          = "latest"
    registry_name      = azurerm_container_registry.container_registry.name
    dockerfile_path    = "${path.cwd}/modules/web_application/source/Dockerfile"
    dockerfile_context = "${path.cwd}/modules/web_application/source"
    dir_sha1           = sha1(join("", [for f in fileset(path.cwd, "modules/web_application/source/*") : filesha1(f)]))
  }
  provisioner "local-exec" {
    command     = "./scripts/docker_build_and_push_to_acr.sh ${var.client_id} ${var.client_secret} ${var.tenant_id} ${var.subscription_id} ${self.triggers.image_name} ${self.triggers.image_tag} ${self.triggers.registry_name} ${self.triggers.dockerfile_path} ${self.triggers.dockerfile_context}"
    interpreter = ["bash", "-c"]
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "asp-web-application-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.web_application_resource_group.name
  kind                = "Linux"
  reserved            = true
  is_xenon            = false
  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
  tags = var.tags
}

resource "random_string" "random_web_application_name" {
  length  = 7
  special = false
  upper   = false
}

resource "azurerm_user_assigned_identity" "app_service_user_assigned_identity" {
  name                = "id-web-application-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.web_application_resource_group.name
  tags                = var.tags
}

resource "azurerm_role_assignment" "app_service_identity_role_assignment" {
  scope                = azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app_service_user_assigned_identity.principal_id
}

resource "azurerm_app_service" "app_service" {
  name                = "app-${random_string.random_web_application_name.result}-prod-${var.location}-001"
  location            = var.location
  resource_group_name = azurerm_resource_group.web_application_resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_service_user_assigned_identity.id]
  }
  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.container_registry.login_server}/samples/dotnet:latest"
  }
  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = azurerm_container_registry.container_registry.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.container_registry.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.container_registry.admin_password
  }
  enabled = true
  tags    = var.tags
}
