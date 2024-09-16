
variable "location" {
  type    = string
  default = "eastus"

}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "user_managed_object_id" {
  type        = string
  description = "value of the user managed identity object id"
}

variable "ipod_db_connection_string" {
  type        = string
  description = "value of the database connection string"
}

variable "ipod_db_connection_string_name" {
  type        = string
  description = "value"
}

resource "random_string" "kv_name" {
  length  = 8
  special = false
}

resource "azurerm_key_vault" "example" {
  name                     = "aca-kv-${random_string.kv_name.result}"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  tenant_id                = var.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.user_managed_object_id

    key_permissions = [
      "all"
    ]

    secret_permissions = [
      "all"
    ]

    certificate_permissions = [
      "all"
    ]
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_key_vault_secret" "db_connection_string" {
  name         = var.ipod_db_connection_string_name
  value        = var.ipod_db_connection_string
  key_vault_id = azurerm_key_vault.example.id
}
