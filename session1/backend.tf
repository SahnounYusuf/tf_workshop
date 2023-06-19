terraform {
  backend "azurerm" {
    resource_group_name  = "AzureRMResource"
    storage_account_name = "azurermtfworkshopstorage"
    container_name       = "tfdemocontainer0"
    key                  = "workshoptf.terraform.tfstate"
  }
}