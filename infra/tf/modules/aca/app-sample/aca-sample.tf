variable "resource_group_name" {
  type = string
}

variable "container_app_environment_id" {
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
    target_port = 80
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
    }
  }
}
