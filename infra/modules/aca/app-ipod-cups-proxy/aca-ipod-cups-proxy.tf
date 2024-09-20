variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "image_name" {
  type = string
}

variable "user_managed_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ipod_app_name" {
  type = string
}

resource "azurerm_container_app" "aca_ipod_cups_proxy" {
  name                         = "aca-ipod-cups-proxy"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  container_app_environment_id = var.container_app_environment_id
  tags                         = var.tags

  ingress {
    target_port = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled = true

  }

  template {
    
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "ipod-cups-proxy"
      image  = var.image_name
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "BACKEND_HOST"
        value = var.ipod_app_name
      }
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