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

# This file creates a virtual network for the on-premises network.
resource "azurerm_virtual_network" "vnet_onprem" {
  name                = "vnet-onprem"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create a subnet for the virtual network
resource "azurerm_subnet" "subnet_onprem" {
  name                 = "subnet-onprem"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_onprem.name
  address_prefixes     = ["10.0.0.0/24"]
}

output "name" {
  value = azurerm_virtual_network.vnet_onprem.name
}

output "id" {
  value = azurerm_virtual_network.vnet_onprem.id
}
