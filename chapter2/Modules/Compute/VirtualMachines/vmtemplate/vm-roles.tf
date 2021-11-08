resource "azurerm_role_assignment" "vm_roles" {
  depends_on = [
    azurerm_linux_virtual_machine.this,
    azurerm_windows_virtual_machine.this,
  ]

  for_each = local.vm_roles

  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  scope = (
    lower(var.vm_type) == "linux" ?
    azurerm_linux_virtual_machine.this[each.value.vm_key].id : azurerm_windows_virtual_machine.this[each.value.vm_key].id
  )
}
