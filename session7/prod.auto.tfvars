resourcename  = "PiCloud"
location      = "North Europe"
storagename   = "azurermtfworkshopstorage"
tags          = { environment = "demo", owner = "sahnoun", purpose = "TFdemo" }
containername = "tfdemocontainer"
dnsname       = ["youssef.com", "sahnoun.com", "joseph.com", "yusuf.com"]
networkrule = [
  {
    # 1st rule
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    # 2nd rule
    name                       = "test124"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    # 3rd rule
    name                       = "test125"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "3389"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

environment              = "staging"
account_tier             = "Standard"
account_replication_type = "GRS"
loc                      = ["east", "us"]
address_space            = ["10.0.0.0/16", "10.0.0.1/32", "10.0.0.1/24", "10.0.2.0/24"]

tags-2 = { resource = "virtualmachine", costcentre = "demotfcourse" }