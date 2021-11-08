variable "tagEnvironment" {
  type        = string
  description = "the environment description"
  default     = "staging"
}

variable "spinExtra" {
  type        = bool
  description = "The Extra Environment to spin"
  default     = false
}

variable "databasePools" {
  type = object({
    sqlpool1 = object(
      {
        type        = string
        name        = string
        sku_name    = string
        create_mode = optional(string)
      }
    )
    sparkpool1 = object(
      {
        type = string
        name = string
      }
    )
  })
  description = "Spark Pool and SQL Pool Configuration"
  default     = { sqlpool1 = { type = "sql", name = "sqlpool1", sku_name = "DW100c", create_mode = "Default" }, sparkpool1 = { type = "spark", name = "sparkpool1" } }
}

variable "stateStore" {
  type        = string
  description = "the storage for the state store"
}

###################################################
# Environment Specs
###################################################
variable "location" {
  type        = string
  description = "The location of the resource group"
  default     = "eastus"
}

variable "environment" {
  type        = string
  description = "The release stage of the environment"
  default     = "dev"
}
variable "rg_name" {
  type        = string
  description = "The name of the resource group"
  default     = "MyResourceGroup"
}

###################################################
# Key Vault Components
###################################################

variable "key_vault_name" {
  type        = string
  description = "the name of the main key vault"
  default     = "mykeyvault"
}
variable "key_vault_resource_id" {
  type        = string
  description = "the resource id of the main key vault"
  default     = "/subscriptions/3d60da7d-bacf-4c0f-9333-16143cd9da70/resourceGroups/rgTerraformLabs/providers/Microsoft.KeyVault/vaults/srramkv123"
}
variable "admin_pw_name" {
  type        = string
  description = "the admin password of the vm"
  default     = "admin-pw"
}

###################################################
# Instance Specific
###################################################

variable "vm_name" {
  type        = string
  description = "the name to give the Virtual Machine"
  default     = "vm"
}


variable "loginId" {
  type        = string
  description = "SP Login"

}

variable "objectId" {
  type        = string
  description = "Object ID"

}

variable "tenantId" {
  type        = string
  description = "Tenant ID"

}

variable "principalName" {
  type        = string
  description = "EA Principal name"

}

variable "synWsName" {
  type        = string
  description = "synapse workspace name"

}

variable "synaddsecObj" {
  description = "Object ID of the user or the service principal"
  type        = set(string)
}

variable "image_build_compute_name" {
  type        = string
  description = "Name of the compute cluster to be created and set to build docker images"
  default     = "image-builder"
}