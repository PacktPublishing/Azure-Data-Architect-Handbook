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
variable "nsg_id" {
  type        = string
  description = "Resource ID of the NSG"
}

variable "training_subnet_address_space" {
  type        = list(string)
  description = "Address space of the training subnet"
  default     = ["10.0.1.0/24"]
}

variable "aks_subnet_address_space" {
  type        = list(string)
  description = "Address space of the aks subnet"
  default     = ["10.0.2.0/24"]
}

variable "ml_subnet_address_space" {
  type        = list(string)
  description = "Address space of the ML workspace subnet"
  default     = ["10.0.3.0/24"]
}

variable "storage_account" {
  type        = string
  description = "Storage account to create a PE for"
}

