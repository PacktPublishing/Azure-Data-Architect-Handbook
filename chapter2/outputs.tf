output "rg_main_output" {
  value = data.azurerm_resource_group.rg_labs
}

/*
output "PubIp" {
  value = data.azurerm_public_ip.pip.ip_address
}
*/
