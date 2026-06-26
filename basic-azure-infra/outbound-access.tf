resource "azurerm_public_ip" "outbound-public-ip" {
  name                = "out-public-ip-basic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "StandardV2"
}

resource "azurerm_nat_gateway" "nat-basic" {
  name                = "nat-basic-infra"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name                = "StandardV2"
  idle_timeout_in_minutes = 4
}

resource "azurerm_nat_gateway_public_ip_association" "nat-public-ip-basic" {
  nat_gateway_id       = azurerm_nat_gateway.nat-basic.id
  public_ip_address_id = azurerm_public_ip.outbound-public-ip.id
}

resource "azurerm_subnet_nat_gateway_association" "subnet-nat-basic" {
  subnet_id      = azurerm_subnet.subnet-basic.id
  nat_gateway_id = azurerm_nat_gateway.nat-basic.id
}
