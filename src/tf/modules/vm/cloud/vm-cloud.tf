variable "location" {
  description = "The location/region where the virtual network is created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the virtual network is created."
  type        = string
}

variable "vm_admin_username" {
  description = "The username for the virtual machine."
  type        = string
}

variable "nic_id" {
  description = "The ID of the network interface."
  type        = string
}

variable "ssh_key" {
  description = "The public SSH key string."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}

#local variables
locals {
  vm_name        = "vm-cloud"
  os_disk_name   = "vm-cloud-osdisk"
  public_ip_name = "vm-cloud-public-ip"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  tags                  = var.tags
  size                  = "Standard_DS2_v2"
  admin_username        = var.vm_admin_username
  network_interface_ids = [var.nic_id]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_key
  }

  os_disk {
    name                 = local.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "public_ip" {
  description = "The public IP address of the virtual machine."
  value       = azurerm_linux_virtual_machine.vm.public_ip_address

}
