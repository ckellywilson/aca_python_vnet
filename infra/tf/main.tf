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

variable "ssh_key_file" {
  description = "SSH public key file"
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

module "ssh" {
  source              = "./modules/ssh"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ssh_key_file        = var.ssh_key_file
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
  ssh_key             = module.ssh.ssh_public_key
  tags                = var.tags
}

module "vm_onprem" {
  source              = "./modules/vm/onprem"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  vm_admin_username   = var.vm_admin_username
  nic_id              = module.vnet_onprem.nic_id
  ssh_key             = module.ssh.ssh_public_key
  tags                = var.tags
}

module "identity" {
  source              = "./modules/identity/user-identity"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

module "aca_env" {
  source                   = "./modules/aca/env"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  infrastructure_subnet_id = module.vnet_cloud.aca_subnet_id
  tags                     = var.tags
}

module "aca_private_dns" {
  source                 = "./modules/dns/private-dns-zone"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  aca_env_default_domain = module.aca_env.aca_default_domain
  aca_static_ip_address  = module.aca_env.aca_static_ip_address
  cloud_vnet_id          = module.vnet_cloud.id
  tags                   = var.tags
}

module "aca_app_sample" {
  source                       = "./modules/aca/app-sample"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = module.aca_env.aca_env_id
  user_assigned_identity_id    = module.identity.identity_id
  tags                         = var.tags
}
