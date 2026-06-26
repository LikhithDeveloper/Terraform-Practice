resource "azurerm_public_ip" "public-ip-basic" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb-basic" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public-ip-basic.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend-pool-basic" {
  loadbalancer_id = azurerm_lb.lb-basic.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "probe-basic" {
  loadbalancer_id     = azurerm_lb.lb-basic.id
  name                = "probe-basic"
  protocol            = "Tcp"
  port                = 22
  interval_in_seconds = 15
  number_of_probes    = 2
  probe_threshold     = 1
}

# resource "azurerm_lb_rule" "lb-rule-basic" {
#   loadbalancer_id = azurerm_lb.lb-basic.id

#   name     = "LBrule"
#   protocol = "Tcp"

#   frontend_port = 50001
#   backend_port  = 22

#   backend_address_pool_ids = [
#     azurerm_lb_backend_address_pool.backend-pool-basic.id
#   ]

#   frontend_ip_configuration_name = "PublicIPAddress"

#   probe_id = azurerm_lb_probe.probe-basic.id
# }

resource "azurerm_lb_nat_pool" "ssh_pool" {
  name                           = "sshpool"
  loadbalancer_id                = azurerm_lb.lb-basic.id
  resource_group_name            = azurerm_resource_group.rg.name
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50099
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}


