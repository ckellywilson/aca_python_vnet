variable "acr_name" {
  description = "The name of the Azure Container Registry"
}

variable "image_name" {
  description = "The name of the image to build"
}

variable "dockerfile_path" {
  description = "The path to the Dockerfile"
}

variable "dockerfile_context" {
  description = "The path to the Dockerfile context"
}

# Set container image name
locals {
  image_tag = formatdate("YYYYMMDD-HHmmss", timestamp())
}

# Create docker image
resource "null_resource" "docker_image" {
  triggers = {
    image_name         = var.image_name
    image_tag          = local.image_tag
    registry_name      = var.acr_name
    dockerfile_path    = var.dockerfile_path
    dockerfile_context = var.dockerfile_context
    # dir_sha1 = sha1(join("", [for f in fileset(path.cwd, "init-app/*") : filesha1(f)]))
  }
  provisioner "local-exec" {
    command = "${path.cwd}/modules/acr/build-image-acr/scripts/docker_build_and_push_to_acr.sh ${self.triggers.image_name} ${self.triggers.image_tag} ${self.triggers.registry_name} ${path.cwd}${self.triggers.dockerfile_path} ${path.cwd}${self.triggers.dockerfile_context}"
  }
}

output "image_name" {
  value = "${var.image_name}:${local.image_tag}"
}
