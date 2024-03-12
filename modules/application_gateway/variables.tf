variable "location" {
  description = "(Required) The location of the Azure resources."
  type        = string
}

variable "location_abbreviation" {
  description = "(Required) The abbreviation of the location used in the name of the Azure resources."
  type        = string
}

variable "tenant_id" {
  description = "(Required) The Azure Tenant ID."
  type        = string
}

variable "application_gateway_subnet_id" {
  description = "(Required) The ID of the Application Gatway subnet."
  type        = string
}

variable "app_service_default_site_hostname" {
  description = "(Required) The Default Hostname associated with the App Service."
  type        = string
}

variable "host_name" {
  description = "(Required) The custom host name for the web application."
  type        = string
}

variable "storage_account_primary_web_host" {
  description = "(Required) The primay web host of the Storage Account static web app."
  type        = string
}

variable "dns_zone_resource_group_name" {
  description = "(Required) The name of the Resource Group with the Azure DNS Zone."
  type        = string
}

variable "dns_zone_name" {
  description = "(Required) The name of the Azure DNS Zone."
  type        = string
}

variable "web_application_subdomain_name" {
  description = "(Required) The name of the web application subdomain."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Azure resources."
  type        = map(any)
  default     = {}
}
