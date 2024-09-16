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

variable "acr_login_server" {
  type = string

}

variable "user_managed_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

resource "azurerm_container_app_job" "aca_print_job" {
  name                         = "aca-print-job"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = 1800

  manual_trigger_config {
  }

  template {
    container {
      name   = "print-job"
      image  = "mcr.microsoft.com/k8se/quickstart-jobs:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.user_managed_id
    ]
  }

  registry {
    server   = var.acr_login_server
    identity = var.user_managed_id
  }

}
