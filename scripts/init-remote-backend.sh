#!/usr/bin/env bash

# This script initializes an Azure remote backend for Terraform by creating the necessary
# storage account and container. It generates a Terraform configuration file with the backend
# settings. The output file can be specified as an argument; if not provided, it defaults
# to 'provider.tf'.

RESOURCE_GROUP_NAME=rso-dev-rg
STORAGE_ACCOUNT_NAME=tfstatebingusi   # needs to be globally unique (across all Azure)
STORAGE_CONTAINER_NAME=tfstate
OUTPUT_FILE=${1:-provider.tf}

# If the output file already exists, prevent overwriting
if [ -f "$OUTPUT_FILE" ]; then
  echo "Error: Output file '$OUTPUT_FILE' already exists. Please remove it or specify a different file."
  exit 1
fi

# Make sure resource group exists
echo "Checking if resource group '$RESOURCE_GROUP_NAME' exists."
if ! az group show --name "$RESOURCE_GROUP_NAME" &>/dev/null; then
  echo "Error: Resource group '$RESOURCE_GROUP_NAME' does not exist."
  exit 1
fi

# Create storage account
echo "Creating storage account '$STORAGE_ACCOUNT_NAME' in resource group '$RESOURCE_GROUP_NAME'."
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --sku Standard_LRS \
  --encryption-services blob \
  --output none

# Retrieve storage account key
ACCOUNT_KEY=$(
  az storage account keys list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query "[0].value" \
  --output tsv
)

# Create storage container
echo "Creating storage container '$STORAGE_CONTAINER_NAME'."
az storage container create \
  --name "$STORAGE_CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$ACCOUNT_KEY" \
  --output none

# Output backend configuration
echo "Writing Terraform backend configuration to '$OUTPUT_FILE'."
cat > "$OUTPUT_FILE" << EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "$RESOURCE_GROUP_NAME"
    storage_account_name  = "$STORAGE_ACCOUNT_NAME"
    container_name        = "$STORAGE_CONTAINER_NAME"
    key                   = "terraform.tfstate"    # modify if necessary, e.g. for different environments
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
EOF
