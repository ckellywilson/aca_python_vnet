variable "location" {
  description = "The location/region where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "aca_env_default_domain" {
  description = "The name of the ACA environment"
  type        = string
}

variable "aca_static_ip_address" {
  description = "The private IP address of the ACA environment"
  type        = string
}

variable "cloud_vnet_id" {
  description = "The ID of the VNet where the ACA environment is deployed"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the resources"
  type        = map(string)
}

locals {
  domain_name_prefix        = regex("^[A-Za-z0-9-]+\\.", var.aca_env_default_domain)
  domain_name_prefix_length = length(local.domain_name_prefix)
  dommain_name_suffix       = substr(var.aca_env_default_domain, local.domain_name_prefix_length, -1)
}

resource "azurerm_private_dns_zone" "aca_private_dns_zone" {
  name                = local.dommain_name_suffix
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "aca_private_dns_record" {
  name                = "*" # Wildcard DNS record
  zone_name           = azurerm_private_dns_zone.aca_private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.aca_static_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "aca_private_dns_zone_vnet_link" {
  name                  = "${azurerm_private_dns_zone.aca_private_dns_zone.name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aca_private_dns_zone.name
  virtual_network_id    = var.cloud_vnet_id
}
