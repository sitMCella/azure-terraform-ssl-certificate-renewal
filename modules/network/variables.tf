variable "location" {
  description = "(Required) The location of the Azure resources."
  type        = string
}

variable "virtual_network_address_space" {
  description = "(Required) The address space of the Virtual Network."
  type        = list(string)
}

variable "application_gateway_subnet_address_prefixes" {
  description = "(Required) The address prefixes of the Application Gateway subnet."
  type        = list(string)
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Azure resources."
  type        = map(any)
  default     = {}
}
