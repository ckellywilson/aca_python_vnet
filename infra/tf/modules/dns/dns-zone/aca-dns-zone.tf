variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "aca_env_host_name" {
  description = "The name of the ACA environment"
  type        = string
}

variable "aca_static_ip_address" {
  description = "The private IP address of the ACA environment"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}

resource "azurerm_private_dns_zone" "aca_private_dns_zone" {
  name                = "${var.location}.azurecontainerapps.io"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_dns_a_record" "aca_private_dns_record" {
  name                = var.aca_env_host_name
  zone_name           = azurerm_private_dns_zone.aca_private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.aca_static_ip_address]
}
