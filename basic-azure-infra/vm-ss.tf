resource "azurerm_linux_virtual_machine_scale_set" "vmss-basic" {
  name                = "basic-infra-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku       = "Standard_D2as_v4"
  instances = 3

  admin_username = "adminuser"
  zones          = ["2", "3"]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("D:/CLOUD/Terraform/azure_vm_key.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vmss-eni"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet-basic.id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.backend-pool-basic.id
      ]

      load_balancer_inbound_nat_rules_ids = [
        azurerm_lb_nat_pool.ssh_pool.id
      ]
    }
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.subnet-nic,
    azurerm_subnet_nat_gateway_association.subnet-nat-basic,
  ]
}
