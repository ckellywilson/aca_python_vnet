variable "prefix" {
  type    = string
  default = "myapp"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tags" {
  type = map(string)
}

resource "azurerm_resource_group" "rg" {
  name     = var.prefix
  location = var.location
  tags = var.tags
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}
