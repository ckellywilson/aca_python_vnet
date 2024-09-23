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

variable "key_vault_uri" {
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

variable "sftp_server" {
  type = string
}

variable "sftp_port" {
  type = number
}

variable "sftp_username" {
  type = string
}

variable "image_name" {
  type = string
}

locals {
  sftp_remote_path = "/home/${var.sftp_username}/upload"
  sftp_local_path  = "/home/${var.sftp_username}/upload"
}

resource "azurerm_container_app_job" "job_sftp_mysql" {
  name                         = "job-sftp-mysql"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = 1800

  schedule_trigger_config {
    cron_expression = "0 * * * *"
  }

  template {
    container {
      name   = "sftp-mysql-job"
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
      env {
        name  = "SFTP_SSH_KEY_PATH"
        value = "/home/${var.sftp_username}/.ssh/ssh-private-key"
      }
      env {
        name  = "SFTP_SERVER"
        value = var.sftp_server
      }
      env {
        name  = "SFTP_PORT"
        value = var.sftp_port
      }
      env {
        name  = "SFTP_USERNAME"
        value = var.sftp_username
      }
      env {
        name  = "SFTP_REMOTE_PATH"
        value = local.sftp_remote_path
      }
      env {
        name  = "SFTP_LOCAL_PATH"
        value = local.sftp_local_path
      }

      volume_mounts {
        name = "ssh-private-key"
        path = "/home/${var.sftp_username}/.ssh/"
      }
    }
    volume {
      name         = "ssh-private-key"
      storage_type = "Secret"
    }
  }

  secret {
    name  = "mysql-password"
    value = var.mysql_password
  }
  secret {
    name                = "ssh-private-key"
    identity            = var.user_managed_id
    key_vault_secret_id = "${var.key_vault_uri}secrets/ssh-private-key"
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
