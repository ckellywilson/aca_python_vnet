variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

resource "azurerm_container_registry" "my_registry" {
  name                = "my-registry"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

output "registry_id" {
  value = azurerm_container_registry.my_registry.id
}
