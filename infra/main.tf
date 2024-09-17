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

variable "tenant_id" {
  description = "Azure tenant ID"
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

variable "ssh_private_key_file" {
  description = "SSH private key file"
  type        = string
}

variable "currrent_user_object_id" {
  description = "User ID"
  type        = string
}

variable "deployment_visibility" {
  description = "Deployment visibility"
  type        = string
}

variable "py_sample_image" {
  description = "Python sample image"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
}

locals {
  resource_group_name                = "${var.prefix}-rg"
  infrastructure_resource_group_name = "${var.prefix}-infra-rg"
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
  name     = local.resource_group_name
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
  source                             = "./modules/aca/env"
  location                           = var.location
  resource_group_name                = azurerm_resource_group.rg.name
  infrastructure_resource_group_name = local.infrastructure_resource_group_name
  infrastructure_subnet_id           = module.vnet_cloud.aca_subnet_id
  deployment_visibility              = var.deployment_visibility
  tags                               = var.tags
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

module "acr_aca" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  prefix              = var.prefix
}

module "role_assign_acr" {
  source              = "./modules/role-assign/acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  principal_id        = module.identity.principal_id
  acr_id              = module.acr_aca.acr_id
}

module "kv_aca" {
  source                    = "./modules/kv"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  tenant_id                 = var.tenant_id
  user_managed_principal_id = module.identity.principal_id
  ssh_private_key_file      = var.ssh_private_key_file
  currrent_user_object_id   = var.currrent_user_object_id
}

module "acr_build_py_sample" {
  source            = "./modules/acr/build-py-sample"
  acr_domain_server = module.acr_aca.acr_login_server
  acr_username      = module.acr_aca.acr_username
  acr_password      = module.acr_aca.acr_password
}

module "aca_py_sample" {
  source                       = "./modules/aca/py-sample"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = module.aca_env.aca_env_id
  user_managed_id              = module.identity.id
  acr_login_server             = module.acr_aca.acr_login_server
  py_sample_image              = var.py_sample_image
  tags                         = var.tags
}

module "mysql_ipod" {
  source              = "./modules/mysql"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  admin_password      = module.kv_aca.mysql_root_password
}

# module "aca_app_ipod" {
#   source                         = "./modules/aca/app-ipod"
#   resource_group_name            = azurerm_resource_group.rg.name
#   container_app_environment_id   = module.aca_env.aca_env_id
#   user_managed_id                = module.identity.id
#   acr_login_server               = module.acr_aca.acr_login_server
#   ipod_db_connection_string      = ""
#   ipod_db_connection_string_name = "ipod-db-connection-string"
#   mysql_host                     = module.mysql_ipod.ip_address
#   tags                           = var.tags
# }

# module "aca_app_ipod_cron" {
#   source                       = "./modules/aca/app-ipod-cron"
#   resource_group_name          = azurerm_resource_group.rg.name
#   container_app_environment_id = module.aca_env.aca_env_id
#   user_managed_id              = module.identity.id
#   acr_login_server             = module.acr_aca.acr_login_server
#   tags                         = var.tags
# }
