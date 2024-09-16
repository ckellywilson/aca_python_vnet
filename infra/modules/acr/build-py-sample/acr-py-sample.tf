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
  image_tag  = "latest"
  image_name = "py-sample"
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

resource "docker_image" "py_sample" {
  name = "${var.acr_domain_server}/${local.image_name}:${local.image_tag}"
  build {
    context    = "${path.cwd}/src/py-sample"
  }
}

resource "docker_registry_image" "push_py_sample" {
  name          = docker_image.py_sample.name
  keep_remotely = false
}
