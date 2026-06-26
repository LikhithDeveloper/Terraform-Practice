resource "azurerm_network_security_group" "database_security_grp" {
  name                = "database_security"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tags = {
    environment = var.environment
  }
  security_rule {
    name                       = "http-rule"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = azurerm_network_interface.database_nic_main.private_ip_address
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ssh-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = azurerm_network_interface.database_nic_main.private_ip_address
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "db-rule"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 120
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = azurerm_network_interface.database_nic_main.private_ip_address
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "database_nic_main" {
  name                = "database_nic"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name = "databaseconfiguration"
    subnet_id = one([
      for s in azurerm_virtual_network.network.subnet :
      s.id if s.name == "testSubnet1"
    ])
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "database_vm" {
  name                             = "vm_database"
  resource_group_name              = azurerm_resource_group.test.name
  location                         = azurerm_resource_group.test.location
  network_interface_ids            = [azurerm_network_interface.database_nic_main.id]
  vm_size                          = "Standard_DS1_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1-database"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.environment
  }
}
