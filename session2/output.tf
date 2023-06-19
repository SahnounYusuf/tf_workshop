output "rgname" {
  value = azurerm_resource_group.resourcegroup
}

output "storage" {
  value = azurerm_storage_account.storage.name
}

output "container" {
  value = azurerm_storage_container.example[*].name
}

output "dnszone" {
  # Syntax: value = [for item in list: output]
  value = [for i in var.dnsname : i]
}
