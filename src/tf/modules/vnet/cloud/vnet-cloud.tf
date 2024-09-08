variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

# This file creates a virtual network for the cloud network.
resource "azurerm_virtual_network" "vnet_cloud" {
  name                = "vnet-cloud"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnet_cloud" {
  name                 = "subnet-cloud"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_cloud.name
  address_prefixes     = ["10.1.0.0/24"]
}

output "name" {
  value = azurerm_virtual_network.vnet_cloud.name
}

output "id" {
  value = azurerm_virtual_network.vnet_cloud.id
}
