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
read -p "Please enter your Azure subscription ID: " subscription_id
echo "subscription_id: $subscription_id"

# get the tenant ID
echo "Getting the tenant ID..."
read -p "Please enter your Azure tenant ID: " tenant_id
echo "tenant_id: $tenant_id"

# get current user id
echo "Getting the current user id..."
currrent_user_object_id=$(az ad signed-in-user show --query "id" --output tsv)
echo "user_id: $currrent_user_object_id"


# create rsa ssh key
echo "Creating rsa ssh key..."
ssh-keygen -m PEM -t ed25519 -f ~/.ssh/id_ed25519
echo "SSH key created successfully."

# Create a tfvars file
echo "Creating a tfvars file..."
cat > main.tfvars <<EOF
prefix            = "rheem"
location          = "$location"
subscription_id   = "$subscription_id"
tenant_id         = "$tenant_id"
vm_admin_username = "vscode"
ssh_key_file = "~/.ssh/id_ed25519.pub"
ssh_private_key_file = "~/.ssh/id_ed25519"
currrent_user_object_id = "$currrent_user_object_id"
deployment_visibility = "Public" # "Public" or "Private"
tags = {
  environment = "dev"
  owner       = "rheem"
}
EOF

# Run Terraform commands using the environment variables
terraform init

# Run Terraform plan
# terraform plan -var-file=main.tfvars -out=tfplan

# Run Terraform apply
terraform apply -var-file=main.tfvars

