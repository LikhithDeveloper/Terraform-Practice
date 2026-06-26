output "nic_id" {
  value = azurerm_network_interface.main.id
}

output "private_ip" {
  value = azurerm_network_interface.main.private_ip_address
}
