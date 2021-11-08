module "shir" {
  source                     = "../../Compute/VirtualMachines/vmtemplate"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  labels_context             = module.labels.context
  label_order                = module.labels.label_order
  project_name               = join("-", compact([module.labels.name, "shir"]))
  vm_name_override           = var.shir_name_prefix
  ad_enabled                 = false
  attributes                 = []
  vm_id                      = 1
  vm_id_format               = "%s"
  vm_count                   = 2
  vm_type                    = "windows"
  vm_disk_encryption_enabled = var.deprecated_disable_vm_encryption_settings ? null : true

  vm_config = {
    size = "Standard_DS3_v2"
    source_image = {
      offer     = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    }
  }

  vm_nic = {
    0 = {
      subnet_id  = var.shir_subnet_id
      lb_enabled = false,
    },
  }

  tags = {
    test = join("-", compact([module.labels.name, "shir"]))
  }
}

locals {
  shir_ext_install_settings = {
    fileUris = [
      "https://raw.githubusercontent.com/favoretti/shir/master/install-gateway.ps1",
      var.integration_runtime_binary_url
    ]
    commandToExecute = "powershell.exe -File \"install-gateway.ps1\" \"${basename(var.integration_runtime_binary_url)}\" \"${azurerm_data_factory_integration_runtime_self_hosted.this.auth_key_1}\""
  }
}

resource "azurerm_virtual_machine_extension" "shir_install_ext" {
  name                 = "shir-installation"
  virtual_machine_id   = module.shir.vm[keys(module.shir.vm)[0]].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = jsonencode(local.shir_ext_install_settings)
}

resource "azurerm_virtual_machine_extension" "shir_install_ext_2" {
  name                 = "shir-installation"
  virtual_machine_id   = module.shir.vm[keys(module.shir.vm)[1]].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = jsonencode(local.shir_ext_install_settings)
}