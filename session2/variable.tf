variable "resourcename" {
  #   default = "Azurermresourcegroup"
  description = "this is a resrouce group"
}
variable "location" {
  #   default = "North Europe"
  description = "The location of the resource group"
}

variable "storagename" {
}

variable "tags" {
  type = map(any)
}

variable "containername" {
}

variable "dnsname" {
  type = list(any)
}

variable "networkrule" {

}

variable "environment" {

}

variable "account_tier" {

}

variable "account_replication_type" {

}

variable "loc" {

}

variable "address_space" {

}