variable "location" {
  description = "The location/region where the virtual machine is created"
}

variable "vm_id" {
  description = "The ID of the virtual machine"
  type        = string
}


# Run the following command to create the "upload" file
resource "azurerm_virtual_machine_run_command" "uploadfiles" {
  name               = "uploadfiles"
  location           = var.location
  virtual_machine_id = var.vm_id

  source {
    script = file("${path.cwd}/software/vm-onprem/uploadfiles.sh")
  }
}

# Run the following command to change sftp port
resource "azurerm_virtual_machine_run_command" "changesfptport" {
  name               = "changesftpport"
  location           = var.location
  virtual_machine_id = var.vm_id

  source {
    script = file("${path.cwd}/software/vm-onprem/changesftpport.sh")
  }
}
