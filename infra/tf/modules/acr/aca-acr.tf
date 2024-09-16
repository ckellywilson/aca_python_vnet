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
  name                = "acaacr${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "acr_id" {
  value = azurerm_container_registry.acr_registry.id
}
