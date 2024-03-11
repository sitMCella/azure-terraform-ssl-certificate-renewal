variable "location" {
  description = "(Required) The location of the Azure resources."
  type        = string
}

variable "location_abbreviation" {
  description = "(Required) The abbreviation of the location used in the name of the Azure resources."
  type        = string
}

variable "domain_name" {
  description = "(Required) The custom domain name for the Azure DNS Zone."
  type        = string
}

variable "host_name" {
  description = "(Required) The custom host name for the web application."
  type        = string
}

variable "key_vault_id" {
  description = "(Required) The ID of the Key Vault."
  type        = string
}

variable "key_vault_name" {
  description = "(Required) The name of the Key Vault."
  type        = string
}

variable "key_name" {
  description = "(Required) The name of the SSL key certificate in the Key Vault."
  type        = string
}

variable "pfx_password" {
  description = "(Required) The password of the SSL certificate in PFX format."
  type        = string
}

variable "email_address" {
  description = "(Required) The email address applied to the SSL Certificate."
  type        = string
}

variable "subscription_id" {
  description = "(Required) The Subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "(Required) The Azure Tenant ID."
  type        = string
}

variable "client_id" {
  description = "(Required) The client ID of the Service Principal Account (App registration)."
  type        = string
}

variable "client_secret" {
  description = "(Required) The client secret of the Service Principal Account (App registration)."
  type        = string
}

variable "application_gateway_resource_group_id" {
  description = "(Required) The ID of the Application Gateway Resource Group."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Azure resources."
  type        = map(any)
  default     = {}
}
