variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "The ID of the subnet where the resources will be created"
  type        = string
}

variable "region" {
  description = "The region where the resources will be created"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)

}

resource "azurerm_log_analytics_workspace" "aca_log_analytics" {
  name                = "aca-log-analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = "aca-environment"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  infrastructure_subnet_id   = var.infrastructure_subnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca_log_analytics.id
  tags                       = var.tags
}

resource "azurerm_private_dns_zone" "aca_private_dns_zone" {
  name                = "${var.region}.azurecontainerapps.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_record" "aca_private_dns_record" {
  name                  = azurerm_container_app_environment.aca_env.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aca_private_dns_zone.name
  ttl                   = 300
  records               = [azurerm_container_app_environment.aca_env.private_ip_address]
  type                  = "A"
}

output "aca_env_id" {
  description = "The ID of the ACA environment"
  value       = azurerm_container_app_environment.aca_env.id
}
