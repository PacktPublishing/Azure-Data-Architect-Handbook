variable "random_resource_trigger" {
  description = "This is not actual password, but a string which, when changed, triggers password resources for new password to be generated."
  type        = string
  default     = "whatever string is"
}

variable "resource_group_name" {
  description = "Azure Resource group name [Mandatory, default is not set]"
  type        = string
}

variable "location" {
  description = "Azure Resource location [Mandatory, default is not set]"
  type        = string
}

variable "labels_context" {
  description = "null-label module context"
  type        = any
  default     = {}
}

variable "attributes" {
  description = "Extra attributes to pass into labels to use as part of Label Module ID output"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "This is name of the project to which belong created resources (usually it is same across all modules in same Resource group)"
  default     = "default value"
}

variable "label_order" {
  description = "Null Label order for ID output"
  type        = list(string)
  default     = ["name", "location", "stage", "attributes"]
}

variable "ad_enabled" {
  description = "Enable / Disable Azure Active Directory integration."
  type        = bool
  default     = false
}

variable "vm_count" {
  description = "How many instances of same type with same config to create"
  type        = number
  default     = 1
}

variable "vm_id" {
  description = "Initial VM Id, added to the end of VM name and/or VM Hostname"
  type        = number
  default     = 1
}

variable "vm_id_format" {
  description = "This is portion of fmt template to use for format() to allow set VM IDs with padding or without padding (default without padding)"
  default     = "%03s"
}

variable "vm_name_override" {
  description = "This name is used only if you want override default hostname (i.e. Windows Hostname limit is 15, but 3 characters is reserved by module)"
  type        = string
  default     = ""
}

variable "vm_type" {
  description = "VM Type Linux or Windows (lower case)"
  type        = string
  default     = "linux"
}

variable "vm_config" {
  description = "Configuration block for VM resource"
  type        = any
  default     = {}
}

variable "vm_nic" {
  description = "List of VM's Network Interface(s) configuration block"
  type        = any
  default     = {}
}

variable "vm_extra_disk" {
  description = "VM's Extra Disk to attach"
  type        = any
  default     = []
}

variable "vm_disk_encryption_enabled" {
  description = "Enable encryption for vm disk, set this to null to remove the encryption_settings block (1.x backward compat)."
  type        = bool
  default     = true
}

variable "vm_ssh_keys" {
  description = "List of Public SSH Keys to use with admin user. If list empty , then password auth is used."
  type        = list(string)
  default     = []
}

variable "vm_admins" {
  description = "Map name => principal ID (AAD User or Group) that have administrator rights in the VM OS. This will count against role assignment limits, considerassigning role on the resource group."
  type        = map(string)
  default     = {}
}

variable "vm_users" {
  description = "Map name => principal ID (AAD User or Group) that have administrator rights in the VM OS. This will count against role assignment limits, considerassigning role on the resource group."
  type        = map(string)
  default     = {}
}

variable "vm_custom_data" {
  description = "Custom Data File's location and provider to use. Supported files: bash script/powershell/cloud-init config. Supported providers cloud-init/waagent. RH/Windows use waagent, ubuntu - cloud-init."
  type        = map(string)
  default = {
    enabled     = false
    provider    = "waagent"
    script_path = ""
  }
}

variable "vm_diagnostic" {
  description = "Configuration Object to enable Boot Diagnostic or/and Logging to target Storage account. (default is disabled)"
  type        = any
  default = {
    boot = false
    logs = false
    storage = {
      name           = ""
      resource_group = ""
    }
  }
}

variable "vm_recovery" {
  description = "Enables VM recovery, all parameters is mandatory"
  type        = map(string)
  default = {
    enabled    = false
    group_name = ""
    vault_name = ""
    policy_id  = ""
  }
}

variable "vm_analytics" {
  description = "Enables Workspace Analytics for VM(s). Workspace should be configured before use."
  type        = map(string)
  default = {
    enabled       = false
    workspace_id  = ""
    workspace_key = ""
  }
}

variable "tags" {
  description = "Global tags to use for module's resources where applicable."
  type        = map(string)
  default     = {}
}

variable "dns_zone" {
  type        = any
  default     = {}
  description = "enable DNS record creation"
}
