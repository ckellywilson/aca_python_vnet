#!/bin/bash

# Login to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Set the prefix
echo "Setting the prefix..."
prefix="rheem"
echo "prefix: $prefix"

# Set location
echo "Setting the location..."
location="southcentralus"
echo "location: $location"

# Variables
# Get subscription ID
echo "Getting the subscription ID..."
subscription_id=$(az account show --query "id" --output tsv)
echo "subscription_id: $subscription_id"

# create rsa ssh key
echo "Creating rsa ssh key..."
ssh-keygen -m PEM -t ed25519 -f ~/.ssh/id_ed25519
echo "SSH key created successfully."

# get public key
echo "Getting public key..."
sshKey=$(cat ~/.ssh/id_ed25519.pub)
echo "sshKey: $sshKey"

# Build py-sample Docker image
# echo "Building py-sample Docker image..."
# docker build -t py-sample:latest --platform=linux/amd64 -f src/py-sample/Dockerfile src/py-sample/.
# echo "py-sample Docker image built successfully."

# Build ipod Docker image
echo "Building ipod Docker image..."
docker build -t ipod:latest --platform=linux/amd64 -f src/ipod/Dockerfile src/ipod/.
echo "ipod Docker image built successfully."

# change to terraform directory
echo "Changing to infra/tf directory..."
cd infra/tf
echo "Current directory: $(pwd)"

# Create a tfvars file
echo "Creating a tfvars file..."
cat > main.tfvars <<EOF
prefix            = "rheem"
location          = "$location"
subscription_id   = "494116cb-e794-4266-98e5-61c178d62cb4"
vm_admin_username = "vscode"
ssh_key_file = "~/.ssh/id_ed25519.pub"
deployment_visibility = "Public" # "Public" or "Private"
py_sample_image = "py-sample:latest"
tags = {
  environment = "dev"
  owner       = "rheem"
}
EOF

# Run Terraform commands using the environment variables
terraform init
#terraform plan -var-file=main.tfvars -out=tfplan
# Run Terraform apply
terraform apply -var-file=main.tfvars

