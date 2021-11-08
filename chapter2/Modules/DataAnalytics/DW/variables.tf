variable "environment_name" {
    description = "Base Name to use for the Environment.  Type prefix or suffix, example \"rg-\", is not necessary.  Naming convention is applied in automation code."
    type = string
    
    validation {
        condition = (
            substr(var.environment_name, 0,3) != "rg-"
        )
        error_message = "Parameter environment_name does not need rg- prefix."
    }
}

variable "tags" {
    description = "Key - Value Map of tags to associate with created resources."
    type = map
}


variable "location" {
    description = "Azure region from https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies"
    type = string
    default = "centralus"
}

variable "resource_group_name" {
    description = "Azure Resource Group"
    type = string
}

variable "storage_account" {
  description = "name of the storage account to be used"
  type        = string
}

variable "sql_administrator_login" {
  description = "Specifies The Login Name of the SQL administrator. Changing this forces a new workspace to be created."
  type        = string
  default     = "sqladmin"
}

variable "psql_administrator_password_keeper" {
  description = "Change this value to regenerate sql_administrator_login password"
  type        = string
  default     = "change-to-reset-password"
}

variable "database_pools" {
  description = "Map of the databases to create for synapse workspace. {<name> = { type = `sql|spark`, name = `string`, sku_name = 'sku', create_mode = 'mode'}"
  type = map(map(string))
  //default = { sqlpool1 = { type = "sql", name = "sqlpool1", sku_name = "DW100c", create_mode = "Default" } }
}

variable "node_size_family" {
  description = "node_size_family"
  type        = string
  default     = "MemoryOptimized"
}

variable "node_size" {
  description = "node_size"
  type        = string
  default     = "Small"
}

variable "max_node_count" {
  description = "maximum number of nodes a spark node pool can have"
  type        = number
  default     = 4
}

variable "min_node_count" {
  description = "minimum number of nodes a spark node pool can have"
  type        = number
  default     = 3
}


variable "managed_virtual_network_enabled" {
  description = "managed vnet for synapse"
  type        = bool
  default     = false
}

variable "aad_admin" {
    description = "admin details"

    type = object({
        login = string
        object_id = string
        tenant_id = string
    })
}



variable "syn_ws_name" {
  description = "synapse workspace name"
  type        = string
}

variable "secObj" {
  description = "Object ID of the user or the service principal"
  type        = set(string)
}