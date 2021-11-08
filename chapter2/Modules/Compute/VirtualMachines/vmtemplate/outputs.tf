output "vm" {
  sensitive = true
  value = {
    for i, v in
    try(var.vm_config.scale_set, false) != true && lower(var.vm_type) == "linux" ?
    tomap(azurerm_linux_virtual_machine.this) : try(var.vm_config.scale_set, false) && lower(var.vm_type) == "linux" ?
    tomap({}) : try(var.vm_config.scale_set, false) != true && lower(var.vm_type) == "windows" ?
    tomap(azurerm_windows_virtual_machine.this) : tomap({})
    :
    v.name => {
      id             = v.id,
      vm_id          = v.virtual_machine_id,
      size           = v.size,
      computer_name  = v.computer_name,
      admin_username = v.admin_username,
      admin_password = v.admin_password,
      principal_id   = v.identity[0].principal_id,
      nic            = v.network_interface_ids,
      disks = [
        for d in keys(azurerm_managed_disk.this) :
        azurerm_managed_disk.this[regex("${i}-\\d", d)].id
        if can(regex("${i}-\\d", d))
      ]
      private_ip          = v.private_ip_address,
      public_ip           = v.public_ip_address,
      resource_group_name = v.resource_group_name,
    }
  }
}
