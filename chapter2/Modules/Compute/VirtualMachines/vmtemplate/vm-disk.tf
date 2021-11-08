/*
 *  We Use keys for for_each to satisfy requirements where for_each need to know at least keys
 *  while values can be calculated later during plan execution
 *  so we use for_each with key maps only and then referencing to map with values
 */

resource "azurerm_managed_disk" "this" {
  for_each = local.vm_disk_keys

  name                 = local.vm_disk[each.key].name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = local.vm_disk[each.key].storage_account_type
  disk_size_gb         = local.vm_disk[each.key].disk_size_gb
  create_option        = local.vm_disk[each.key].create_option
  os_type              = var.vm_type
  disk_iops_read_write = local.vm_disk[each.key].disk_iops_read_write
  disk_mbps_read_write = local.vm_disk[each.key].disk_mbps_read_write
  zones                = can(var.vm_config.zone) ? var.vm_config.zone : null

  dynamic "encryption_settings" {
    for_each = var.vm_disk_encryption_enabled == null ? [] : [1]
    content {
      enabled = var.vm_disk_encryption_enabled
    }
  }

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}


resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  depends_on = [
    azurerm_linux_virtual_machine.this,
    azurerm_windows_virtual_machine.this,
  ]

  for_each = local.vm_disk_keys

  managed_disk_id = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = (
    lower(var.vm_type) == "linux" ?
    azurerm_linux_virtual_machine.this[local.vm_disk[each.key].vm_host_id].id : azurerm_windows_virtual_machine.this[local.vm_disk[each.key].vm_host_id].id
  )
  lun                       = local.vm_disk[each.key].lun
  caching                   = local.vm_disk[each.key].caching
  create_option             = "Attach"
  write_accelerator_enabled = local.vm_disk[each.key].write_accelerator_enabled
}
