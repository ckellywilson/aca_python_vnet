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

locals {
  nsgrules = {

    sftp = {
      name                       = "sftp"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "4422"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
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

resource "azurerm_public_ip" "public_ip_onprem" {
  name                = "public-ip-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# Create a network interface for the subnet
resource "azurerm_network_interface" "nic_onprem" {
  name                = "nic-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-onprem"
    subnet_id                     = azurerm_subnet.subnet_onprem.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_onprem.id
  }
}

resource "azurerm_network_security_group" "nsg_onprem" {
  name                = "nsg-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_onprem_association" {
  network_interface_id      = azurerm_network_interface.nic_onprem.id
  network_security_group_id = azurerm_network_security_group.nsg_onprem.id
}

# Create network security group rules
resource "azurerm_network_security_rule" "nsg_onprem_rules" {
  for_each = local.nsgrules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_onprem.name
}

output "id" {
  value = azurerm_virtual_network.vnet_onprem.id
}

output "name" {
  value = azurerm_virtual_network.vnet_onprem.name
}

output "nic_id" {
  value = azurerm_network_interface.nic_onprem.id
}
