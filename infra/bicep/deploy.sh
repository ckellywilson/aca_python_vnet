#!/bin/bash

# Login to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Variables
# Get the Azure AD signed-in user ID
echo "Getting the Azure AD signed-id user ID..."
adminUserId=$(az ad signed-in-user show --query "id" --output tsv)
echo "adminUserId: $adminUserId"

# Set the prefix for all resources
echo "Setting the prefix for all resources..."
prefix="rheem"
echo "prefix: $prefix"

# Set the deployment name
echo "Setting the deployment name..."
deploymentName="${prefix}-deployment"
echo "deploymentName: $deploymentName"

# Generate ssh key
echo "Generating ssh key..."
ssh-keygen -m PEM -t ed25519 -f ~/.ssh/id_ed25519.pem
echo "SSH key generated successfully."

# Get ssh public key
echo "Getting ssh public key..."
sshPublicKey=$(cat ~/.ssh/${prefix}-id_rsa.pub)
echo "sshPublicKey: $sshPublicKey"

# Set the location
echo "Setting the location..."
location="centralus"
echo "location: $location"

# Deploy AKS cluster using Bicep template
echo "Deploying AKS cluster using Bicep template..."
az deployment sub create --name $deploymentName \
    --location $location \
    --parameters ./bicep/main.bicepparam \
    --parameters prefix="$prefix" \
    --parameters adminUserId="$adminUserId" \
    --template-file ./bicep/main.bicep
echo "Deployment completed successfully."

# show the outputs
echo "Showing the outputs..."
az deployment sub show --name $deploymentName --query "properties.outputs"