resource "azurerm_dns_a_record" "linux" {
  for_each            = var.dns_zone != {} && lower(var.vm_type) == "linux" ? azurerm_linux_virtual_machine.this : {}
  name                = lower(each.value.computer_name)
  zone_name           = var.dns_zone.name
  resource_group_name = var.dns_zone.resource_group_name
  records             = [each.value.private_ip_address]
  ttl                 = 300
  tags                = module.labels.tags
}

resource "azurerm_dns_a_record" "windows" {
  for_each            = var.dns_zone != {} && lower(var.vm_type) == "windows" ? azurerm_windows_virtual_machine.this : {}
  name                = lower(each.value.computer_name)
  zone_name           = var.dns_zone.name
  resource_group_name = var.dns_zone.resource_group_name
  records             = [each.value.private_ip_address]
  ttl                 = 300
  tags                = module.labels.tags
}