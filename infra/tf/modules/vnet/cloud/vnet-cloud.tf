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
  address_prefixes     = ["10.1.0.0/23"]
}

resource "azurerm_subnet" "subnet_cloud_aca" {
  name                 = "subnet-cloud-aca"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_cloud.name
  address_prefixes     = ["10.1.2.0/23"]
}

resource "azurerm_public_ip" "public_ip_cloud" {
  name                = "public-ip-cloud"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "nic_cloud" {
  name                = "nic-cloud"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig-cloud"
    subnet_id                     = azurerm_subnet.subnet_cloud.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_cloud.id
  }
}

resource "azurerm_network_security_group" "nsg_cloud" {
  name                = "nsg-cloud"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_cloud_association" {
  network_interface_id      = azurerm_network_interface.nic_cloud.id
  network_security_group_id = azurerm_network_security_group.nsg_cloud.id
}

output "id" {
  value = azurerm_virtual_network.vnet_cloud.id
}

output "name" {
  value = azurerm_virtual_network.vnet_cloud.name
}

output "cloud_subnet_id" {
  value = azurerm_subnet.subnet_cloud.id
}

output "aca_subnet_id" {
  value = azurerm_subnet.subnet_cloud_aca.id
}

output "nic_id" {
  value = azurerm_network_interface.nic_cloud.id
}
