
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

variable "user_managed_principal_id" {
  type        = string
  description = "value of the user managed identity object id"
}

variable "mysql_root_password" {
  type        = string
  description = "value of the mysql root password"
  sensitive   = true
}

variable "mysql_ipod_password" {
  type        = string
  description = "value of the mysql ipod password"
  sensitive   = true

}

variable "ssh_private_key_file" {
  type        = string
  description = "value of the ssh private key"
}

variable "currrent_user_object_id" {
  type        = string
  description = "value of the current user object id"
}

resource "random_string" "kv_name" {
  length  = 8
  special = false
}

resource "azurerm_key_vault" "aca_kv" {
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
    object_id = var.user_managed_principal_id

    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Delete"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Recover",
      "Delete"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Recover",
      "Delete"
    ]
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.currrent_user_object_id

    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Delete"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Recover",
      "Delete"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Recover",
      "Delete"
    ]
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_key_vault_secret" "mysql_root_password" {
  name         = "mysql-root-password"
  value        = var.mysql_root_password
  key_vault_id = azurerm_key_vault.aca_kv.id
}

resource "azurerm_key_vault_secret" "mysql_ipod_password" {
  name         = "mysql-ipod-password"
  value        = var.mysql_ipod_password
  key_vault_id = azurerm_key_vault.aca_kv.id
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = file(var.ssh_private_key_file)
  key_vault_id = azurerm_key_vault.aca_kv.id
}