variable "acr_domain_server" {
  description = "The fully qualified domain name of the Azure Container Registry"
}

variable "acr_username" {
  description = "The username for the Azure Container Registry"

}

variable "acr_password" {
  description = "The password for the Azure Container Registry"

}

locals {
  image_tag  = formatdate("YYYYMMDD-HHmmss", timestamp())
  image_name = "ipod"
}

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = var.acr_domain_server
    username = var.acr_username
    password = var.acr_password
  }
}

resource "docker_image" "ipod" {
  name = "${var.acr_domain_server}/${local.image_name}:${local.image_tag}"
  build {
    context    = "${path.cwd}/../src/ipod"
  }
}

resource "docker_registry_image" "push_ipod" {
  name          = docker_image.ipod.name
  keep_remotely = false
}

output "image_name" {
  value = docker_image.ipod.name
}