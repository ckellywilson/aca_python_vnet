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

resource "azurerm_mysql_flexible_database" "ipod_db" {
  name                = "ipod_db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.ipod_mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# this should allow connections from Azure services
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = azurerm_mysql_flexible_server.ipod_mysql.resource_group_name
  server_name         = azurerm_mysql_flexible_server.ipod_mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
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

