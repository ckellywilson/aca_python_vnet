variable "prefix" {
  description = "The prefix to be used for all resources in this module."
  type        = string
}

variable "location" {
  description = "The location/region where the SSH key should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the SSH key should be created."
  type        = string
}

variable "ssh_key_file" {
  description = "The SSH key to be used for authentication."
  type        = string
}

resource "azurerm_ssh_public_key" "ssh" {
  name                = "${var.prefix}-ssh-key"
  location            = var.location
  resource_group_name = var.resource_group_name
  public_key          = file(var.ssh_key_file)

}

output "ssh_public_key" {
  value = azurerm_ssh_public_key.ssh.public_key
}
