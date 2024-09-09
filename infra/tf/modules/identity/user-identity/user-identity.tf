variable "prefix" {
  description = "A prefix to add to the beginning of the generated resource names."
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the user assigned identity."
}

variable "location" {
  description = "The location/region where the user assigned identity should be created."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

resource "azurerm_user_assigned_identity" "user_managed_identity" {
  name                = "aca-managed-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

output "identity_id" {
  description = "The ID of the user assigned identity."
  value       = azurerm_user_assigned_identity.user_managed_identity.id
}
