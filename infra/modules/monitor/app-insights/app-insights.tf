variable "location" {
  description = "The location/region where the Application Insights should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the Application Insights should be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}

resource "azurerm_application_insights" "app_insights" {
  name                = "ipod-app-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags                = var.tags
}

output "app_insights_connection_string" {
  value = azurerm_application_insights.app_insights.connection_string
}
