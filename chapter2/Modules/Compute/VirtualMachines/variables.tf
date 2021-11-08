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
variable "subnet" {
  type        = string
  description = "Resource ID of the subnet to join"
}
variable "user" {
  type        = string
  description = "Admin user for the VM"
}
variable "vm_name" {
  type        = string
  description = "Name to give the VM"
}
variable "password" {
  type        = string
  sensitive   = true
  description = "Password for the VM"
}
