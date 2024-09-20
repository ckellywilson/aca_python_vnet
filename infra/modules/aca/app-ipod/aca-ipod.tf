variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "ipod_image" {
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

variable "mysql_password" {
  type = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "appinsights_connection_string" {
  type = string
}

resource "random_string" "secret" {
  length  = 16
  special = true
  upper = true
}

resource "azurerm_container_app" "aca_ipod" {
  name                         = "aca-ipod"
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
      name   = "ipod"
      image  = var.ipod_image
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
        secret_name = "mysql-password"
      }
      env {
        name  = "MYSQL_HOST"
        value = var.mysql_host
      }
      env {
        name  = "MYSQL_SSL_CAMYSQL_SSL_CA"
        value = "/app/DigiCertGlobalRootCA.crt.pem"
      }
      env {
        name  = "DJANGO_PRODUCTION"
        value = "True"
      }
      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = var.appinsights_connection_string
      }
      env {
        secret_name = "secret-key"
        name = "SECRET_KEY"
      }
      env {
        name  = "ALLOWED_HOSTS"
        value = "*"
      }
      env {
        name  = "MYSQL_PORT"
        value = "3306"
      }
    }
  }

  secret {
    name  = "secret-key"
    value = random_string.secret.result
  }

  secret {
    name = "mysql-password"
    value = var.mysql_password
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
