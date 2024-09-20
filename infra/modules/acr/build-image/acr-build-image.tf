variable "acr_domain_server" {
  description = "The fully qualified domain name of the Azure Container Registry"
}

variable "acr_username" {
  description = "The username for the Azure Container Registry"

}

variable "acr_password" {
  description = "The password for the Azure Container Registry"
}

variable "image_name" {
  description = "The name of the image to build"
}

variable "docker_path" {
  description = "The path to the Dockerfile"
}

locals {
  image_tag  = formatdate("YYYYMMDD-HHmmss", timestamp())
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

resource "docker_image" "image" {
  name = "${var.acr_domain_server}/${var.image_name}:${local.image_tag}"

  build {
    context    = "${path.cwd}${var.docker_path}"
    labels = {
      "Author" = "PKA"
    }
  }
  # triggers = {
  #   dir_sha1 = sha1(join("", [for f in fileset(path.module, "${path.cwd}${var.docker_path}/*") : filesha1(f)]))
  # }
}

resource "docker_registry_image" "push_image" {
  name          = docker_image.image.name
  keep_remotely = false
}

output "image_name" {
  value = docker_image.image.name
}