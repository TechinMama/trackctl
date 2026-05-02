terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Backend config is supplied at init time via -backend-config flags.
  # Bootstrap the storage account once with:
  #   az group create -n rg-athena-tfstate -l eastus2
  #   az storage account create -n satfstateathena -g rg-athena-tfstate --sku Standard_LRS --min-tls-version TLS1_2
  #   az storage container create -n tfstate --account-name satfstateathena
  # Then add three GitHub secrets:
  #   TF_BACKEND_RESOURCE_GROUP  = rg-athena-tfstate
  #   TF_BACKEND_STORAGE_ACCOUNT = satfstateathena
  #   TF_BACKEND_CONTAINER       = tfstate
  # CI validate requires required backend arguments to exist in config.
  # Real values are passed from workflow secrets during terraform init.
  backend "azurerm" {
    resource_group_name  = "placeholder"
    storage_account_name = "placeholder"
    container_name       = "placeholder"
    key                  = "placeholder.tfstate"
  }
}

provider "azurerm" {
  features {}
}
