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

# create ed25519 ssh key
echo "Creating ed25519 ssh key..."
ssh-keygen -m PEM -t ed25519 -f ~/.ssh/id_ed25519 -q -N ""
echo "SSH key created successfully."

# get public key
echo "Getting public key..."
sshKey=$(cat ~/.ssh/id_ed25519.pub)
echo "sshKey: $sshKey"

# Set service principal name
echo "Setting the service principal name..."
spName="${prefix}-sub-sp"
echo "spName: $spName"

# Create the service principal
json=$(az ad sp create-for-rbac --name $spName --role Contributor --scopes /subscriptions/${subscription_id})

# Get App ID
echo "Getting the App ID..."
appId=$(az ad sp list --query "[?displayName=='$spName'].appId" --all --output tsv)
echo "appId: $appId"


# read password
echo "Reading password..."
password=$(echo $json | jq -r .password)
echo "password: $password"

# Store the output in Terraform environment variables
export ARM_CLIENT_ID=$appId
export ARM_CLIENT_SECRET=$password
export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_TENANT_ID=$(az account show --query tenantId --output tsv)

# Create a tfvars file
echo "Creating a tfvars file..."
cat > main.tfvars <<EOF
prefix            = "rheem"
location          = "southcentralus"
subscription_id   = "494116cb-e794-4266-98e5-61c178d62cb4"
vm_admin_username = "vscode"
ssh_key      = "$sshKey"
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