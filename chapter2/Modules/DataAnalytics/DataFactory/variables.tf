variable "location" {
    description = "Azure region from https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies"
    type = string
    default = "centralus"
}


variable "storage_account" {
  description = "name of the storage account to be used"
  type        = string
}

variable "managed_virtual_network_enabled" {
  description = "managed vnet for synapse"
  type        = bool
  default     = false
}

variable "principalname" {
  description = "Service Principal"
  type        = string
}

variable "adfname" {
  description = "adfname"
  type        = string
}

variable "tags" {
    description = "Key - Value Map of tags to associate with created resources."
    type = map
}

variable "name" {
  description = "ADF Name"
  type        = string
  default     = "srramadf1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "labels_context" {
  description = "null-label module context"
  type        = string
  default     = "e30="
}

variable "resource_group_name" {
  description = "Name of the resource group to use for this module."
  type        = string
  default     = "srramterraformstate"
}

variable "adf_contributors" {
  description = "Name and id of the principals that get contributor over ADF"
  type        = map(string)
  default     = {}
}

variable "adf_readers" {
  description = "Name and id of the principals that get reader over ADF"
  type        = map(string)
  default     = {}
}

variable "adf_rg_data_factory_contributors" {
  description = "Name and id of the principals that get Data Factory Contributor over ADF's own RG"
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "Azure tenant id"
  type        = string
  default     = "50460471-2197-4938-8e96-0708f3384c45"
}


variable "shir_name_prefix" {
  description = "Name prefix for integration runtime VMs. The name will be <prefix>NN, which must be unique in the VNET."
  type        = string
  default     = "srramshir-"
}

variable "shir_subnet_id" {
  description = "Subnet ID to put shared integration runtime into"
  type        = string
  default     = "/subscriptions/3d60da7d-bacf-4c0f-9333-16143cd9da70/resourceGroups/rgTerraformLabs/providers/Microsoft.Network/virtualNetworks/dev-network/subnets/subnet1"
}

variable "spn_owners" {
  description = "List(string) of the principals to make owners of the spervice principal"
  type        = list(string)
  default     = ["eff3524e-fba8-45c6-ac3d-e502ec6af06e"]
}

variable "storage_accounts" {
  description = "Storage accounts this ADF is going to work with."
  type = map(object({
    id  = string
    url = string
  }))
  default = {}
}

variable "integration_runtime_name" {
  description = "Name of the Integration Runtime to be created"
  type        = string
  default     = "sh-integration-runtime"
}

variable "kv_readers" {
  description = "Map (name => principal_id) of security principals that can read all."
  type        = map(string)
  default     = {"srramkvreaders" : "eff3524e-fba8-45c6-ac3d-e502ec6af06e"}
}

variable "kv_admins" {
  description = "Map (name => principla_id) of security principals that full rights to key vault contents."
  type        = map(string)
  default     = {srramkvadmins="eff3524e-fba8-45c6-ac3d-e502ec6af06e"}
}

variable "kv_listers" {
  description = "Map (name => principal_id) of security principals that can list secrets."
  type        = map(string)
  default     = {}
}

variable "kv_secrets" {
  description = "Map name => value of the secrets to add to this vault"
  type        = map(string)
  default     = {srramkvsecrets="eff3524e-fba8-45c6-ac3d-e502ec6af06e"}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace where Diagnostics Data should be sent."
  type        = string
  default     = "/subscriptions/3d60da7d-bacf-4c0f-9333-16143cd9da70/resourcegroups/sr-mgmt/providers/microsoft.operationalinsights/workspaces/sr-la-3d60da7d-bacf-4c0f-9333-16143cd9da70"
}

variable "private_endpoints" {
  description = "Create private endpoint for this storage account."
  type = map(object({
    subnet_id            = string
    subresource_name     = string
    private_dns_zone_id  = string
    is_manual_connection = bool
  }))
  default = {}
}

variable "deprecated_disable_vm_encryption_settings" {
  description = "Disable VM encryption settings. Deprecated and must not be used."
  type        = bool
  default     = false
}

variable "alerts" {
  description = "Create alerts for this ADF"
  type = map(object({
    enabled       = optional(bool)
    auto_mitigate = optional(bool)
    description   = optional(string)
    frequency     = optional(string)
    severity      = optional(number)
    window_size   = optional(string)

    action = optional(list(object({
      group_id           = string
      webhook_properties = optional(map(string))
    })))

    criteria = list(object({
      metric_namespace = optional(string)
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = string

      dimension = optional(list(object({
        name     = string
        operator = string
        values   = list(string)
      })))
    }))
  }))

  default = {}
}

variable "logs" {
  description = "Configure ADF diagnostic settings for logs."

  type = object({
    enabled        = optional(bool)
    retention_days = optional(number)
  })

  default = {
    enabled        = false
    retention_days = 0
  }
}

variable "metrics" {
  description = "Configure ADF diagnostic settings for metrics."

  type = object({
    enabled        = optional(bool)
    retention_days = optional(number)
  })

  default = {
    enabled        = true
    retention_days = 5
  }
}

variable "integration_runtime_binary_url" {
  description = "Integration runtime binary download URL"
  type        = string
  default     = "https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.8.7856.3.msi"
}

