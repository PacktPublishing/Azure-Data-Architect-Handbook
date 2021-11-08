output "subnet_id" {
  value = azurerm_virtual_network.main.subnet.*.id[0]
}