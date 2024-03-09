variable "tenant_id" {
  description = "(Required) The Azure Tenant ID."
}

variable "subscription_id" {
  description = "(Required) The Subscription ID."
}

variable "client_id" {
  description = "(Required) The client ID of the Service Principal Account (App registration)."
}

variable "client_secret" {
  description = "(Required) The client secret of the Service Principal Account (App registration)."
}

variable "location" {
  description = "(Required) The location of the Azure resources."
}

variable "location_abbreviation" {
  description = "(Required) The abbreviation of the location used in the name of the Azure resources."
}
