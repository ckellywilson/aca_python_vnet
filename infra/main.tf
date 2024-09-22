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
    random = {
      source  = "hashicorp/random"
      version = "~>3.6.3"
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

# execute command on vnet_onprem
module "vm_onprem_command" {
  source   = "./modules/vm/onprem/command"
  location = var.location
  vm_id    = module.vm_onprem.vm_id
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

module "mysql_ipod" {
  source              = "./modules/mysql"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  admin_password      = module.kv_aca.mysql_root_password
}

################# ACR IMAGES #################
# builds docker image using acr
module "acr_null_build_py_sample" {
  source             = "./modules/acr/build-image-acr"
  acr_name           = module.acr_aca.acr_name
  image_name         = "py-sample"
  dockerfile_path    = "/../src/py-sample/Dockerfile"
  dockerfile_context = "/../src/py-sample"
}

module "acr_null_build_ipod" {
  source             = "./modules/acr/build-image-acr"
  acr_name           = module.acr_aca.acr_name
  image_name         = "ipod"
  dockerfile_path    = "/../src/ipod/Dockerfile"
  dockerfile_context = "/../src/ipod"
}

module "acr_null_build_ipod_cups_proxy" {
  source             = "./modules/acr/build-image-acr"
  acr_name           = module.acr_aca.acr_name
  image_name         = "ipod-cups-proxy"
  dockerfile_path    = "/../src/cups-proxy/Dockerfile"
  dockerfile_context = "/../src/cups-proxy"
}

module "acr_null_build_mysql_cron" {
  source             = "./modules/acr/build-image-acr"
  acr_name           = module.acr_aca.acr_name
  image_name         = "ipod-mysql-job"
  dockerfile_path    = "/../src/mysql-job/Dockerfile"
  dockerfile_context = "/../src/mysql-job"
}

module "sftp_get_job" {
  source             = "./modules/acr/build-image-acr"
  acr_name           = module.acr_aca.acr_name
  image_name         = "sftp-get-job"
  dockerfile_path    = "/../src/sftp-get-job/Dockerfile"
  dockerfile_context = "/../src/sftp-get-job"
}

################# ACA APPS #################
# this deploys the app to the container
module "aca_py_sample" {
  source                       = "./modules/aca/py-sample"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = module.aca_env.aca_env_id
  user_managed_id              = module.identity.id
  acr_login_server             = module.acr_aca.acr_login_server
  py_sample_image              = module.acr_null_build_py_sample.image_name
  tags                         = var.tags

  depends_on = [module.acr_null_build_py_sample]
}

module "aca_app_ipod" {
  source                        = "./modules/aca/app-ipod"
  resource_group_name           = azurerm_resource_group.rg.name
  container_app_environment_id  = module.aca_env.aca_env_id
  user_managed_id               = module.identity.id
  acr_login_server              = module.acr_aca.acr_login_server
  mysql_host                    = module.mysql_ipod.ip_address
  mysql_password                = module.kv_aca.mysql_root_password
  appinsights_connection_string = ""
  image_name                    = module.acr_null_build_ipod.image_name
  tags                          = var.tags

  depends_on = [module.acr_null_build_ipod]
}

module "aca_app_ipod_cups_proxy" {
  source                       = "./modules/aca/app-ipod-cups-proxy"
  resource_group_name          = azurerm_resource_group.rg.name
  container_app_environment_id = module.aca_env.aca_env_id
  user_managed_id              = module.identity.id
  acr_login_server             = module.acr_aca.acr_login_server
  image_name                   = module.acr_null_build_ipod_cups_proxy.image_name
  tags                         = var.tags
  ipod_app_name                = module.aca_app_ipod.aca_app_name
  depends_on                   = [module.aca_app_ipod]
}

module "aca_job_mysql_cron" {
  source                       = "./modules/aca/job-mysql-cron"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = var.location
  container_app_environment_id = module.aca_env.aca_env_id
  user_managed_id              = module.identity.id
  acr_login_server             = module.acr_aca.acr_login_server
  mysql_host                   = module.mysql_ipod.ip_address
  mysql_password               = module.kv_aca.mysql_root_password
  image_name                   = module.acr_null_build_mysql_cron.image_name
  tags                         = var.tags

  depends_on = [module.acr_null_build_mysql_cron]
}
