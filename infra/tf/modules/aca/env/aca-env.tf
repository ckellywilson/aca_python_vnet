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

  workload_profile {
    name                  = "aca-workload-profile"
    workload_profile_type = "Consumption"
  }
}

output "aca_env_id" {
  description = "The ID of the ACA environment"
  value       = azurerm_container_app_environment.aca_env.id
}

output "aca_static_ip_address" {
  description = "The private IP address of the ACA environment"
  value       = azurerm_container_app_environment.aca_env.static_ip_address
}

output "aca_default_domain" {
  description = "The host name of the ACA environment"
  value       = azurerm_container_app_environment.aca_env.default_domain
}
