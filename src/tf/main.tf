variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "vm_admin_username" {
  description = "Username for the VM"
  type        = string
  sensitive   = true
}

variable "ssh_key" {
  description = "SSH public key"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

module "vnet_onprem" {
  source              = "./modules/vnet/onprem"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "vnet_cloud" {
  source              = "./modules/vnet/cloud"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "vnet_peering" {
  source              = "./modules/vnet/peering"
  vnet_onprem_name    = module.vnet_onprem.name
  vnet_onprem_id      = module.vnet_onprem.id
  vnet_cloud_name     = module.vnet_cloud.name
  vnet_cloud_id       = module.vnet_cloud.id
  resource_group_name = azurerm_resource_group.rg.name
}

module "vm_cloud" {
  source              = "./modules/vm/cloud"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_admin_username   = var.vm_admin_username
  nic_id              = module.vnet_cloud.nic_id
  ssh_key             = var.ssh_key
  tags                = var.tags
}

module "vm_onprem" {
  source              = "./modules/vm/onprem"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_admin_username   = var.vm_admin_username
  nic_id              = module.vnet_onprem.nic_id
  ssh_key             = var.ssh_key
  tags                = var.tags
}

