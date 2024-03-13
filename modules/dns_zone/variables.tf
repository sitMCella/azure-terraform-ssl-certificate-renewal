variable "location" {
  description = "(Required) The location of the Azure resources."
  type        = string
}

variable "domain_name" {
  description = "(Required) The custom domain name for the Azure DNS Zone."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Azure resources."
  type        = map(any)
  default     = {}
}