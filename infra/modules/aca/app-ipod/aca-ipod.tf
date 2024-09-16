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

variable "ipod_db_connection_string" {
  type        = string
  description = "value"
}

variable "ipod_db_connection_string_name" {
  type        = string
  description = "value"
}

variable "mysql_host" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_container_app" "aca_sample" {
  name                         = "aca-sample"
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  container_app_environment_id = var.container_app_environment_id
  tags                         = var.tags

  ingress {
    target_port = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    external_enabled = true
  }

  template {
    container {
      name   = "quickstart"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "MYSQL_DATABASE"
        value = "ipod"
      }
      env {
        name  = "MYSQL_USER"
        value = "ipuser"
      }
      env {
        name  = "MYSQL_PASSWORD"
        value = "ipodpassword"
      }
      env {
        name  = "MYSQL_HOST"
        value = var.mysql_host
      }
      env {
        name  = "MYSQL_PORT"
        value = "3306"
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
