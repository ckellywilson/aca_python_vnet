resource "random_string" "prefix" {
  length  = 6
  special = false
  upper   = false
}

variable "location" {
  type    = string
  default = "eastus"

}

variable "resource_group_name" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_mysql_flexible_server" "ipod_mysql" {
  name                   = "${random_string.prefix.result}-ipod-mysql"
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = "ipodadmin"
  administrator_password = var.admin_password
  sku_name               = "GP_Standard_D2ds_v4"
  version                = "8.0.21"
  backup_retention_days  = 7

  tags = var.tags
}

output "name" {
  value = azurerm_mysql_flexible_server.ipod_mysql.name
}

output "ip_address" {
  value = azurerm_mysql_flexible_server.ipod_mysql.fqdn
}

output "admin_username" {
  value = azurerm_mysql_flexible_server.ipod_mysql.administrator_login
}

