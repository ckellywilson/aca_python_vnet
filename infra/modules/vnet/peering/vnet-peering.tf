variable "vnet_onprem_name" {
  description = "The name of the on-premises virtual network to peer with"
}

variable "vnet_onprem_id" {
  description = "The ID of the on-premises virtual network to peer with"
}

variable "vnet_cloud_name" {
  description = "The name of the cloud virtual network to peer with"
}

variable "vnet_cloud_id" {
  description = "The ID of the cloud virtual network to peer with"
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the virtual network peering"
}

resource "azurerm_virtual_network_peering" "vnet_peering_onprem_to_cloud" {
  name                         = "vnet-peering-onprem-to-cloud"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.vnet_onprem_name
  remote_virtual_network_id    = var.vnet_cloud_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "vnet_peering_cloud_to_onprem" {
  name                         = "vnet-peering-cloud-to-onprem"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = var.vnet_cloud_name
  remote_virtual_network_id    = var.vnet_onprem_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

output "vnet_peering_onprem_to_cloud_id" {
  value = azurerm_virtual_network_peering.vnet_peering_onprem_to_cloud.id
}

output "vnet_peering_cloud_to_onprem_id" {
  value = azurerm_virtual_network_peering.vnet_peering_cloud_to_onprem.id
}
