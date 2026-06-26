terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "8b7a585a-d2f4-41c5-ad7a-5a08dd71cbf0"
  features {}
}

resource "azurerm_resource_group" "rg-group" {
  name     = "Test-windows-server"
  location = "Canada Central"
}

resource "azurerm_virtual_network" "vnet-desktop" {
  name                = "Test_Vnet_for_windows_vm-2"
  location            = azurerm_resource_group.rg-group.location
  resource_group_name = azurerm_resource_group.rg-group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.rg-group.name
  virtual_network_name = azurerm_virtual_network.vnet-desktop.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg-basic" {
  name                = "windows-vm-nsg"
  location            = azurerm_resource_group.rg-group.location
  resource_group_name = azurerm_resource_group.rg-group.name

  security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
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
    name                       = "HTTPS"
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

resource "azurerm_subnet_network_security_group_association" "subnet-nic" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.nsg-basic.id
}

resource "azurerm_public_ip" "vm-pip" {
  name                = "windows-vm-public-ip"
  location            = azurerm_resource_group.rg-group.location
  resource_group_name = azurerm_resource_group.rg-group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "vm-nic" {
  name                = "windows-vm-nic"
  location            = azurerm_resource_group.rg-group.location
  resource_group_name = azurerm_resource_group.rg-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-pip.id
  }
}

resource "azurerm_windows_virtual_machine" "windows-vm" {
  name                = "windowsvm01"
  resource_group_name = azurerm_resource_group.rg-group.name
  location            = azurerm_resource_group.rg-group.location
  size                = "Standard_D2as_v4"
  zone                = "1"

  admin_username = "azureuser"
  admin_password = "P@ssword1234!"

  network_interface_ids = [
    azurerm_network_interface.vm-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.vm-pip.ip_address
}
