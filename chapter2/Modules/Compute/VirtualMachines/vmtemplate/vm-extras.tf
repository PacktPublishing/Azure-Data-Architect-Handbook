data "azurerm_subscription" "current" {}

// Boot Diagnostic URL
data "azurerm_storage_account" "this" {
  for_each            = toset(try(var.vm_diagnostic.bot, false) || try(var.vm_diagnostic.logs, false) ? ["diagnostic"] : [])
  name                = var.vm_diagnostic.storage.name
  resource_group_name = var.vm_diagnostic.storage.resource_group
}

// SAS Token for Logging if enabled
data "azurerm_storage_account_sas" "this" {
  for_each          = toset(try(var.vm_diagnostic.bot, false) || try(var.vm_diagnostic.logs, false) ? ["logs"] : [])
  connection_string = data.azurerm_storage_account.this["diagnostic"].primary_connection_string
  https_only        = false

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = "2020-01-01T00:00:01Z"
  expiry = "2100-01-31T23:59:59Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

# data "template_file" "windiagconf" {
#   template = "${file("${path.module}/files/winDiagConfig.xml")}"
# }

# data "template_file" "linuxdiagconf" {
#   template = "${file("${path.module}/files/linuxDiagConfig.json")}"
# }

# "\"${base64encode(data.template_file.windiagconf.rendered)}\"" : replace(data.template_file.linuxdiagconf.rendered, "__VM_RESOURCE_ID__", format("%s/resourceGroups/%s/providers/Microsoft.Compute/virtualMachines/%s", data.azurerm_subscription.current.id, var.resource_group_name, format("%s%s", local.vm_name, local.vm_numbers[count.index])))

resource "azurerm_virtual_machine_extension" "azure_monitoring_diagnostics" {
  for_each = try(var.vm_diagnostic.logs, false) ? merge(
    try(nonsensitive(azurerm_linux_virtual_machine.this), azurerm_linux_virtual_machine.this),
  try(nonsensitive(azurerm_windows_virtual_machine.this), azurerm_windows_virtual_machine.this)) : {}

  name                       = lower(var.vm_type) == "linux" ? "LinuxDiagnostic" : "Microsoft.Insights.VMDiagnosticsSettings"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = lower(var.vm_type) == "linux" ? "LinuxDiagnostic" : "IaaSDiagnostics"
  type_handler_version       = lower(var.vm_type) == "linux" ? "3.0" : "1.5"
  auto_upgrade_minor_version = true

  # The JSON file referenced below was created by running "az vm diagnostics get-default-config --is-windows-os", and adding/verifying the "__DIAGNOSTIC_STORAGE_ACCOUNT__" and "__VM_RESOURCE_ID__" placeholders.
  # settings = format("%q", jsonencode(each.value.settings))
  settings = jsonencode(merge(
    (lower(var.vm_type) == "linux" ? tomap({ ladCfg = jsondecode(templatefile("${path.module}/files/linuxDiagConfig.json", { vm_id = each.value.id })) }) : {}),
    (lower(var.vm_type) == "windows" ? tomap({ xmlCfg = base64encode(templatefile("${path.module}/files/winDiagConfig.xml", { vm_id = each.value.id })) }) : {}),
    tomap({ storageAccount = data.azurerm_storage_account.this["diagnostic"].name }),
  ))

  # Diagnostic Settings (to store VM diagnostic/metrics to Azure Storage Account)
  # https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html
  protected_settings = jsonencode({
    (lower(var.vm_type) == "linux" ? "storageAccountSasToken" : "storageAccountKey") = (
      lower(var.vm_type) == "linux" ?
      data.azurerm_storage_account_sas.this["logs"].sas : data.azurerm_storage_account.this["diagnostic"].primary_access_key
    ),
    storageAccountName = data.azurerm_storage_account.this["diagnostic"].name,
  })

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

# OMS Extension (Azure Monitoring)
# https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html
resource "azurerm_virtual_machine_extension" "analytics" {
  for_each = try(var.vm_analytics.enabled, false) ? merge(
    try(nonsensitive(azurerm_windows_virtual_machine.this), azurerm_windows_virtual_machine.this),
  try(nonsensitive(azurerm_linux_virtual_machine.this), azurerm_linux_virtual_machine.this)) : {}

  name                       = lower(var.vm_type) == "linux" ? "OmsAgentForLinux" : "MicrosoftMonitoringAgent"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = lower(var.vm_type) == "linux" ? "OmsAgentForLinux" : "MicrosoftMonitoringAgent"
  type_handler_version       = lower(var.vm_type) == "linux" ? "1.8" : "1.0"
  auto_upgrade_minor_version = true
  settings                   = jsonencode({ workspaceId = var.vm_analytics.workspace_id })
  protected_settings         = jsonencode({ workspaceKey = var.vm_analytics.workspace_key })

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

# Azure AD Extension Linux
resource "azurerm_virtual_machine_extension" "azure_ad_vm_extension" {
  for_each = var.ad_enabled && lower(var.vm_type) == "linux" ? try(nonsensitive(azurerm_linux_virtual_machine.this), azurerm_linux_virtual_machine.this) : {}

  name                       = "AADLoginForLinux"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
  type                       = "AADLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

# Azure AD Extension Windows
resource "azurerm_virtual_machine_extension" "azure_ad_windows_vm_extension" {
  for_each = var.ad_enabled && lower(var.vm_type) == "windows" ? try(nonsensitive(azurerm_windows_virtual_machine.this), azurerm_windows_virtual_machine.this) : {}

  name                       = "AADLoginForWindows"
  virtual_machine_id         = each.value.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

# Backup Policy
# https://www.terraform.io/docs/providers/azurerm/r/recovery_services_protected_vm.html
resource "azurerm_backup_protected_vm" "backup" {
  for_each = try(var.vm_recovery.enabled, false) ? merge(
    try(nonsensitive(azurerm_windows_virtual_machine.this), azurerm_windows_virtual_machine.this),
  try(nonsensitive(azurerm_linux_virtual_machine.this), azurerm_linux_virtual_machine.this)) : {}

  resource_group_name = var.vm_recovery.group_name
  recovery_vault_name = var.vm_recovery.vault_name
  source_vm_id        = each.value.id
  backup_policy_id    = var.vm_recovery.policy_id

  # Added due to issue with Origin-Shipped-Test vault case sensitivity
  # Remove in future if needed however you may need to run the problem VMs at a specific version of this module
  lifecycle { ignore_changes = [source_vm_id, backup_policy_id] }
  # Also added backup_policy_id as something else weird going on with case sensitivity on all VMs!
}

# All Extensions supported by WA Agent
# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/overview

# Virtual Machine Extension to Execute Custom Scripts Linux
# https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux
resource "azurerm_virtual_machine_extension" "linux_wa_agent" {
  for_each = (
    local.vm_custom_data.enabled && local.vm_custom_data.provider == "waagent" && local.vm_custom_data != "" && lower(var.vm_type) == "linux" ?
    try(nonsensitive(azurerm_linux_virtual_machine.this), azurerm_linux_virtual_machine.this) : {}
  )

  name                 = "LinuxCustomScriptExecution"
  virtual_machine_id   = each.value.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  protected_settings = jsonencode(
    {
      script          = filebase64(local.vm_custom_data.script_path),
      managedIdentity = {}
    }
  )

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

# Microsoft.Azure.Extensions.CustomScript
resource "azurerm_virtual_machine_extension" "windows_wa_agent" {
  for_each = (
    local.vm_custom_data.enabled && local.vm_custom_data.provider == "waagent" && local.vm_custom_data != "" && lower(var.vm_type) == "windows" ?
    try(nonsensitive(azurerm_windows_virtual_machine.this), azurerm_windows_virtual_machine.this) : {}
  )

  name                 = "WindowsCustomScriptExecution"
  virtual_machine_id   = each.value.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  protected_settings = jsonencode(
    {
      commandToExecute = "powershell.exe (Invoke-Command -ScriptBlock ([ScriptBlock]::Create((Get-Content '\\AzureData\\CustomData.bin'))))"
    }
  )

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

