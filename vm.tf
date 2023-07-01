provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resgrp" {
  name     = "keerthi"
  location = "West US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resgrp.location
  resource_group_name = azurerm_resource_group.resgrp.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.resgrp.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "network-interface"
  location            = azurerm_resource_group.resgrp.location
  resource_group_name = azurerm_resource_group.resgrp.name

  ip_configuration {
    name                          = "ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "vm-001"
  location              = azurerm_resource_group.resgrp.location
  resource_group_name   = azurerm_resource_group.resgrp.name
  vm_size               = "Standard_DS2_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  tags = {
    ScheduledStart = "Yes"
    ScheduledStop  = "Yes"
  }

  network_interface_ids = [azurerm_network_interface.nic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-01"
    admin_username = "keer"
    admin_password = "azureuser@123"  # Note: Use a strong password and consider using secrets management systems instead
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


