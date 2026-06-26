resource "azurerm_resource_group" "test" {
  name     = "test-resource"
  location = "South Africa North"
  tags = {
    environment = var.environment
  }
}

resource "azurerm_network_security_group" "network_security" {
  name                = "test-security"
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
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "https-rule"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pub_ip" {
  name                = "test-ip-public"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_network" "network" {
  name                = "test-vent"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
  subnet {
    name             = "testSubnet1"
    address_prefixes = ["10.0.1.0/24"]
    security_group   = azurerm_network_security_group.network_security.id
  }
  tags = {
    environment = var.environment
  }
}

# resource "azurerm_network_interface" "main" {
#   name                = "test-nic"
#   location            = azurerm_resource_group.test.location
#   resource_group_name = azurerm_resource_group.test.name

#   ip_configuration {
#     name = "testconfiguration1"
#     subnet_id = one([
#       for s in azurerm_virtual_network.network.subnet :
#       s.id if s.name == "testSubnet1"
#     ])
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pub_ip.id
#   }
# }

module "web-nic" {
  source = "./modules/nic"

  name                = "test-nic"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_config_name      = "testconfiguration1"
  subnet_id = one([
    for s in azurerm_virtual_network.network.subnet :
    s.id if s.name == "testSubnet1"
  ])
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id          = azurerm_public_ip.pub_ip.id

}

resource "azurerm_virtual_machine" "name" {
  name                             = "test-vm"
  resource_group_name              = azurerm_resource_group.test.name
  location                         = azurerm_resource_group.test.location
  network_interface_ids            = [module.web-nic.nic_id]
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
    name              = "myosdisk1"
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


