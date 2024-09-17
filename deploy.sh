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

# get the tenant ID
echo "Getting the tenant ID..."
tenant_id=$(az account show --query "tenantId" --output tsv)
echo "tenant_id: $tenant_id"

# get current user id
echo "Getting the current user id..."
currrent_user_object_id=$(az ad signed-in-user show --query "id" --output tsv)
echo "user_id: $currrent_user_object_id"


# create rsa ssh key
echo "Creating rsa ssh key..."
ssh-keygen -m PEM -t ed25519 -f ~/.ssh/id-ed25519
echo "SSH key created successfully."

# change to terraform directory
echo "Changing to infra/tf directory..."
cd infra/tf
echo "Current directory: $(pwd)"

# Create a tfvars file
echo "Creating a tfvars file..."
cat > ./infra/main.tfvars <<EOF
prefix            = "rheem"
location          = "$location"
subscription_id   = "$subscription_id"
tenant_id         = "$tenant_id"
vm_admin_username = "vscode"
ssh_key_file = "~/.ssh/id-ed25519.pub"
ssh_private_key_file = "~/.ssh/id-ed25519"
currrent_user_object_id = "$currrent_user_object_id"
deployment_visibility = "Public" # "Public" or "Private"
py_sample_image = "py-sample:latest"
tags = {
  environment = "dev"
  owner       = "rheem"
}
EOF

# Run Terraform commands using the environment variables
terraform -chdir="./infra" init
#terraform plan -var-file=main.tfvars -out=tfplan
# Run Terraform apply
terraform -chdir="./infra" apply -var-file=main.tfvars

