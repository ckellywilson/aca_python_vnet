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

    min_replicas = 1
    max_replicas = 3

    container {
      name   = "ipod"
      image  = var.image_name
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

# https://learn.microsoft.com/en-gb/azure/container-apps/ingress-how-to?pivots=azure-cli#use-additional-tcp-ports

locals {
  yaml_content = templatefile("${path.module}/aca-ipod-template.yaml.tpl", {
    image_name     = var.image_name
    mysql_host     = var.mysql_host
  })
}

resource "local_file" "aca_ipod_yaml" {
  content  = local.yaml_content
  filename = "${path.module}/aca-ipod.yaml"
}

resource "null_resource" "configure_ingress" {
  provisioner "local-exec" {
    command = <<EOT
      az containerapp update \
        --name ${azurerm_container_app.aca_ipod.name} \
        --resource-group ${var.resource_group_name} \
        --yaml ${path.module}/aca-ipod.yaml
    EOT
  }

  depends_on = [
    azurerm_container_app.aca_ipod
  ]
}

output "aca_app_name" {
  value = azurerm_container_app.aca_ipod.name
}