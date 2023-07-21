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


resource "azurerm_resource_group" "resourcegroup" {
  name     = var.resourcename
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "azvnet" {
  name                = "azurevnettfnetwork"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  address_space       = [element(var.address_space, 0)]
}

resource "azurerm_subnet" "azsubnet" {
  name                 = "subnetfortfcourse"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes     = [element(var.address_space, 3)]
}

resource "azurerm_network_security_group" "nsgrule" {
  name                = "Azurenetworksecuritygrouprules"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location

  dynamic "security_rule" {
    iterator = rule
    for_each = var.networkrule
    content {
      name                       = rule.value.name
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_port_range          = rule.value.source_port_range
      destination_port_range     = rule.value.destination_port_range
      source_address_prefix      = rule.value.source_address_prefix
      destination_address_prefix = rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_public_ip" "publicip" {
  count               = 3
  name                = "publicip${count.index}"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "vm-nic${count.index}"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  ip_configuration {
    name                          = "testipconfig"
    subnet_id                     = azurerm_subnet.azsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.publicip.*.id, count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  count                     = 3
  network_interface_id      = element(azurerm_network_interface.nic.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsgrule.id
}

resource "azurerm_virtual_machine" "vm-slave" {
  count                 = 2
  name                  = "slave-vm-${count.index}"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  vm_size               = "Standard_B1s"


  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ubuntu${count.index}"
    admin_username = "ubuntu${count.index}"
    admin_password = "user_123"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      key_data = file("id_rsa.pub")
      path     = "/home/ubuntu${count.index}/.ssh/authorized_keys"
    }
  }

  tags = merge(var.tags, var.tags-2)
}

resource "azurerm_virtual_machine" "vm-master" {
  name                  = "azure-vm-master"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.nic.2.id]
  vm_size               = "Standard_B2s"


  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ubuntu"
    admin_username = "ubuntu"
    admin_password = "user_123"
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      key_data = file("id_rsa.pub")
      path     = "/home/ubuntu/.ssh/authorized_keys"
    }
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = "user_123"
    private_key = file("id_rsa")
    host        = azurerm_public_ip.publicip.2.ip_address
  }

  provisioner "file" {
    source      = "ansible"
    destination = "/home/ubuntu/ansible"
  }
 
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible",
    ]
  }


  tags = merge(var.tags, var.tags-2)
}