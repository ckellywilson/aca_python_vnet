variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

resource "azurerm_container_app" "aca-sample" {
  name                         = "aca-sample"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  revision_mode                = "Manual"
  container_app_environment_id = var.container_app_environment_id

  template {
    container {
      name   = "quickstart"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.5
      memory = "1.5"
    }
  }
}

resource "azurerm_resource_group" "my_resource_group" {
  name     = "my-resource-group"
  location = "eastus"
}
