variable "resource_group_name" {
  type = string
}

variable "location" {
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

variable "mysql_host" {
  type = string
}

variable "mysql_password" {
  type      = string
  sensitive = true
}

variable "image_name" {
  type = string
}

resource "azurerm_container_app_job" "aca_mysql_job" {
  name                         = "aca-mysql-job"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = 1800

  schedule_trigger_config {
    cron_expression = "0 * * * *"
  }

  template {
    container {
      name   = "sql-job"
      image  = "${var.acr_login_server}/${var.image_name}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "MYSQL_DATABASE"
        value = "ipod_db"
      }
      env {
        name  = "MYSQL_USER"
        value = "ipodadmin"
      }
      env {
        name        = "MYSQL_PASSWORD"
        secret_name = "mysql-password"
      }
      env {
        name  = "MYSQL_HOST"
        value = var.mysql_host
      }
      env {
        name  = "MYSQL_SSL_CA"
        value = "/app/DigiCertGlobalRootCA.crt.pem"
      }
      env {
        name  = "MYSQL_PORT"
        value = "3306"
      }
    }
  }

  secret {
    name  = "mysql-password"
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
