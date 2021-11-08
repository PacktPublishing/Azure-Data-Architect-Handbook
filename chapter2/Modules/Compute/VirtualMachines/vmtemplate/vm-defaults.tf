locals {

  vm_custom_data_defaults = {
    enabled     = false
    provider    = "waagent"
    script_path = ""
  }

  vm_custom_data = merge(local.vm_custom_data_defaults, var.vm_custom_data)

  vm_disk_default_account_type = "StandardSSD_LRS"

  vm_defaults = {
    computer_name       = null            // Used when resource name and VM hostname require some difference (for example for automation system based on hostnames)
    scale_set           = false           // Use VMSS instead of regular VM, have higher priority over regular VM and availability_set
    zone                = null            // zones as list even if single zone specified, not used if scale_set is false
    availability_set_id = null            // if set and scale_set = false, then availability_set is used.
    size                = "Standard_B8ms" // Size of VM
    ultra_ssd           = false           // additional_capabilities -> https://www.terraform.io/docs/providers/azurerm/r/linux_virtual_machine.html#ultra_ssd_enabled

    admin_auth = {
      admin_username = "srramadmin"
      admin_password = ""
      # disable_password_authentication = false
      # ssh_enabled                     = false
      # public_keys                     = []
    }

    os_disk = {
      name                      = null
      caching                   = "ReadWrite"
      storage_account_type      = local.vm_disk_default_account_type
      write_accelerator_enabled = false
      disk_size_gb              = null
    }

    // Windows supported parameters
    enable_automatic_updates = lower(var.vm_type) == "windows" ? true : null
    license_type             = lower(var.vm_type) == "windows" ? "Windows_Server" : null // None, Windows_Client and Windows_Server


    source_image = lower(var.vm_type) == "windows" ? local.windows_default_image : local.linux_default_image

    identity = {
      type         = "SystemAssigned"
      identity_ids = null
    }
  }

  // VM Recovery Defaults
  vm_recovery_defaults = {
    group_name    = ""
    vault_id      = ""
    backup_policy = ""
  }
  // merge defaults with received values
  vm_recovery = merge(local.vm_recovery_defaults, var.vm_recovery)

  // Linux Default Image
  linux_default_image = {
    id        = null
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "7-RAW-CI"
    urn       = "RedHat:RHEL:7-RAW-CI:7.7.2019081601"
    version   = "7.7.2019081601"
  }
  // Windows Default Image
  windows_default_image = {
    id        = null
    offer     = "WindowsServer",
    publisher = "MicrosoftWindowsServer",
    sku       = "2016-Datacenter",
    #urn       = "MicrosoftWindowsServer:WindowsServer:2016-Datacenter:2016.127.20190603",
    version = "latest"
  }
  /*
    Defaults for Managed disks when 'extra_disk' specified by configuration
    supported storage_account_type: Standard_LRS/Premium_LRS/StandardSSD_LRS/UltraSSD_LRS
    NOTE: UltraSSD_LRS - is in private preview only so publicly not available
          disk_iops_read_write and disk_mbps_read_write Can be used only if 'UltraSSD_LRS' for storage_account_type is set.
  */
  vm_disk_defaults = {
    lun                       = null
    storage_account_type      = local.vm_disk_default_account_type
    create_option             = "Empty"
    disk_size_gb              = "50"
    disk_iops_read_write      = null
    disk_mbps_read_write      = null
    caching                   = "ReadWrite"
    write_accelerator_enabled = false
  }

  vm_nic_defaults = {
    id                            = null
    app_gw_enabled                = false
    app_gw_pool                   = ""
    lb_enabled                    = false
    lb_pool                       = ""
    app_gw_pool                   = ""
    enable_accelerated_networking = false
    dns_servers                   = null
    enable_ip_forwarding          = false
    pool_type                     = "loadbalancer"
    pool_id                       = ""
    // ip_configuration block defaults (Module have support only for one IP configuration per NIC!)
    subnet_id                     = ""
    primary                       = null
    private_ip_address_version    = "IPv4"    // Possible IPv4 or IPv6
    private_ip_address_allocation = "Dynamic" // Possible Static / Dynamic
    ip_config_name                = "internal"
    public_ip_address_id          = null
    private_ip_address            = null
  }

  // merging sub-maps to cover defaults
  vm_maps = {
    for k, v in var.vm_config :
    k => merge(local.vm_defaults[k], v)
    if can(merge(local.vm_defaults[k], v))
  }

  // Merge extra disk defaults
  vm_extra_disk = {
    extra_disk = contains(keys(var.vm_config), "extra_disk") ? [
      for d in var.vm_config["extra_disk"] :
      merge(local.vm_disk_defaults, d)
    ] : []
  }

  // final merge of defaults with passed options and maps from from previous step
  vm_final_merge = merge(local.vm_defaults, var.vm_config, local.vm_maps, local.vm_extra_disk)

  /*
   *  This block holding actual maps with parameters to use for specific resources
   *  1) Actual VM resource(s)
   *  2) Disk Resource(s)
   *  3) NIC Resource(s)
   */

  // Build Resources map using range and vm_count parameter
  vm_count = toset(range(var.vm_count))

  // Create VM Map where index is future VM resource id (aka vm_host_id parameter in various maps) in state and value is merged configuration
  // Also null-ed some config parameters not required for vm resource directly (we have it already in vm_final_merge)
  // Pre-build name for resources

  vm_keys = {
    for v in local.vm_count :
    format("%s-%s", "vm", v) => v
  }

  vm = {
    for v in local.vm_count :
    format("%s-%s", "vm", v) => merge(
      local.vm_final_merge,
      // Due Windows instance limitations
      { name = format("%s-${var.vm_id_format}", module.labels.id, var.vm_id + v) },
      // Due some limitations we use `vm_name_override` only with linux, and windows use `vm_name_override` as replacement for `name`
      { computer_name = var.vm_name_override != "" ? format("%s${var.vm_id_format}", var.vm_name_override, var.vm_id + v) : null },
    )
  }

  vm_role_definitions = {
    user = {
      role_definition_name = "Virtual Machine User Login"
      users                = var.vm_users
    }
    admin = {
      role_definition_name = "Virtual Machine Administrator Login"
      users                = var.vm_admins
    }
  }

  vm_role_keys = flatten([
    for k, v in local.vm_keys : [
      for rname, role in local.vm_role_definitions : [
        for name, id in role.users :
        format("%s-%s-%s", k, name, rname)
      ]
    ]
  ])

  vm_role_values = flatten([
    for k, v in local.vm_keys : [
      for rname, role in local.vm_role_definitions : [
        for name, id in role.users :
        {
          role_definition_name = role.role_definition_name
          principal_id         = id
          vm_key               = k
        }
      ]
    ]
  ])

  vm_roles = zipmap(local.vm_role_keys, local.vm_role_values)

  // Extra disk as list of objects
  /*
      {
        id = 0              // Mandatory, This is used as 'lun' and mandatory to set, should be unique per disk->instance
        name = "Logs"       // Optional,  If set appended to the end of Disk name
        disk_size_gb = 100  // Optional,  Default value per disk is 50GB
        ....                // Any parameter specified in 'linux_disk_defaults' can be placed here to override default behaviors
      }
    */
  // Create VM Disks map where index is vm resource id + lun index of disk, value is disk parameters plus vm state id
  // Used to create Disks and Disk Attachments to target VM(s) by vm_host_id
  // State IDs created by formula 'vm-<current vm_count>-<disk.Id>'
  // Pre-build name for resources

  vm_disk_keys = merge(flatten([[
    for v in local.vm_count : {
      for disk in try(var.vm_extra_disk, []) :
      format("%s-%s-%s", "vm", v, disk.lun) => format("%s-%s-%s", "vm", v, disk.lun)
    }
  ]])...)

  vm_disk = merge(flatten([[
    for v in local.vm_count : {
      for disk in try(var.vm_extra_disk, []) :
      format("%s-%s-%s", "vm", v, disk.lun) => merge(
        local.vm_disk_defaults,
        disk,
        { name = format("%s-${var.vm_id_format}-%s", module.labels.id_with_suffix.disk, var.vm_id + v, disk.lun) },
        { vm_host_id = format("%s-%s", "vm", v) },
      )
    }
  ]])...)



  vm_nic_keys = merge(flatten([[
    for v in local.vm_count : {
      for id in toset(keys(var.vm_nic)) :
      format("%s-%s-%s", "vm", v, id) => {
        id             = format("%s-%s-%s", "vm", v, id)
        lb_enabled     = contains(keys(var.vm_nic[id]), "lb_enabled") ? var.vm_nic[id].lb_enabled : false
        app_gw_enabled = contains(keys(var.vm_nic[id]), "app_gw_enabled") ? var.vm_nic[id].lb_enabled : false
      }
    }
  ]])...)

  vm_nic = merge(flatten([[
    for v in local.vm_count : {
      for id in toset(keys(var.vm_nic)) :
      format("%s-%s-%s", "vm", v, id) => merge(
        local.vm_nic_defaults,
        var.vm_nic[id],
        { id = id },
        { name = format("%s-${var.vm_id_format}-%s","nic", var.vm_id + v, id) },
        { vm_host_id = format("%s-%s", "vm", v) },
      )
    }
  ]])...)

  assert_custom_name_do_not_fit = (
    length(var.vm_name_override) > 12 && lower(var.vm_type) == "windows" ?
    file("\n\nERROR: Windows does not support long hostnames (15 characters, 3 reserved for module), keep vm_custom_name maximum 12 characters!") : null
  )
}
