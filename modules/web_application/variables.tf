variable "location" {
  description = "(Required) The location of the Azure resources."
  type        = string
}

variable "tenant_id" {
  description = "(Required) The Azure Tenant ID."
  type        = string
}

variable "subscription_id" {
  description = "(Required) The Subscription ID."
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

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Azure resources."
  type        = map(any)
  default     = {}
}
