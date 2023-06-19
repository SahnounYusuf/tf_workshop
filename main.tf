# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


module "vnetwork" {
    source = "Azure/vnet/azurerm"
    resource_group_name = ""
    address_space = []
    subnet_prefixes = []
    subnet_names = []

    subnet_service_endpoints = {
        subnet2 = []
        subnet3 = []
    }

    tags = {
        environment = "dev"
        contcenter = "it"
    }

    depends_on = [ azurerm_resource_group.example ]
}