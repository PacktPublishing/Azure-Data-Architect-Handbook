resource "azurerm_windows_virtual_machine" "this" {
  depends_on = [
    azurerm_network_interface.this,
    azurerm_managed_disk.this,
  ]

  for_each = try(var.vm_config.scale_set, false) != true && lower(var.vm_type) == "windows" ? local.vm_keys : {}

  name                     = local.vm[each.key].name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  size                     = local.vm[each.key].size
  availability_set_id      = local.vm[each.key].availability_set_id
  zone                     = local.vm[each.key].zone != null ? local.vm[each.key].zone[0] : null
  enable_automatic_updates = local.vm[each.key].enable_automatic_updates
  license_type             = local.vm[each.key].license_type
  computer_name            = local.vm[each.key].computer_name
  custom_data = (
    local.vm_custom_data.enabled && local.vm_custom_data.script_path != "" ?
    filebase64(local.vm_custom_data.script_path) : null
  )

  additional_capabilities {
    ultra_ssd_enabled = local.vm[each.key].ultra_ssd
  }

  dynamic "boot_diagnostics" {
    iterator = diag
    for_each = try(var.vm_diagnostic.boot, false) ? tomap({ diag = data.azurerm_storage_account.this["diagnostic"].primary_blob_endpoint }) : {}
    content {
      storage_account_uri = diag.value
    }
  }

  // If User and/or Password is empty then used auto-generated credentials
  admin_username = (
    local.vm[each.key].admin_auth.admin_username != "" ?
    local.vm[each.key].admin_auth.admin_username : random_string.username[each.key].result
  )
  admin_password = (
    local.vm[each.key].admin_auth.admin_password != "" ?
    local.vm[each.key].admin_auth.admin_password : random_password.password[each.key].result
  )

  // OS disk Configuration
  dynamic "os_disk" {
    iterator = os
    for_each = tomap({ os_disk = local.vm[each.key].os_disk })
    content {
      name                 = format("%s-%s", local.vm[each.key].name, "osdisk")
      caching              = os.value.caching
      storage_account_type = os.value.storage_account_type
      disk_size_gb         = os.value.disk_size_gb
    }
  }

  // Source Image, depends on configuration we can use or source_image_id or source_image_reference
  source_image_id = local.vm[each.key].source_image.id

  dynamic "source_image_reference" {
    iterator = image
    for_each = local.vm[each.key].source_image.id != null && local.vm[each.key].source_image.id != "" ? {} : tomap({ image = local.vm[each.key].source_image })
    content {
      offer     = image.value.offer
      publisher = image.value.publisher
      sku       = image.value.sku
      version   = image.value.version
    }
  }

  // Configure Identity
  dynamic "identity" {
    iterator = auth
    for_each = tomap({ identity = local.vm[each.key].identity })
    content {
      type         = auth.value.type
      identity_ids = auth.value.identity_ids
    }
  }

  network_interface_ids = [
    for i in keys(azurerm_network_interface.this) :
    azurerm_network_interface.this[regex("${each.key}-\\d", i)].id
    if can(regex("${each.key}-\\d", i))
  ]

  tags = merge(module.labels.tags, var.tags, {
    project-name = var.project_name,
    hostname = (local.vm[each.key].computer_name != "" && local.vm[each.key].computer_name != null ?
      local.vm[each.key].computer_name : local.vm[each.key].name
    ),
  })
}
