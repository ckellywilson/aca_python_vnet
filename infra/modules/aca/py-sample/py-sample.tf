variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "user_managed_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "py_sample_image" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_container_app" "py-sample" {
  name                         = "py-sample"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  container_app_environment_id = var.container_app_environment_id
  tags                         = var.tags

  ingress {
    target_port = 5002
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled = true
  }

  template {
    container {
      name   = "py-sample"
      image  = var.py_sample_image
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
