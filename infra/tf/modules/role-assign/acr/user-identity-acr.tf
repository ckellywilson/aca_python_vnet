variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "user_identity_id" {
  type = string
}

variable "acr_id" {
  type = string
}

resource "azurerm_role_assignment" "acr_role_assignment" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.user_identity_id

}
