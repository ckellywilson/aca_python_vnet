resource "random_string" "prefix" {
  length  = 6
  special = false
  upper   = false
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

resource "azurerm_container_registry" "acr_registry" {
  name                = "acaacr${var.prefix}${random_string.prefix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "acr_id" {
  value = azurerm_container_registry.acr_registry.id
}

output "acr_login_server" {
  value = azurerm_container_registry.acr_registry.login_server
}

output "acr_username" {
  value = azurerm_container_registry.acr_registry.admin_username
}

output "acr_password" {
  value = azurerm_container_registry.acr_registry.admin_password
}

output "acr_name" {
  value = azurerm_container_registry.acr_registry.name
}
