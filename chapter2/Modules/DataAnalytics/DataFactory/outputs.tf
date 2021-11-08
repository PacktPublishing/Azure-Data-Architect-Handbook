output "id" {
  description = "The ID of the Data Factory"
  value       = azurerm_data_factory.this.id
}

output "principal_id" {
  description = "ADF managed identity principal ID"
  value       = azurerm_data_factory.this.identity[0].principal_id
}

output "tenant_id" {
  description = "ADF managed identity tenant ID"
  value       = azurerm_data_factory.this.identity[0].tenant_id
}

output "penp_labels" {
  value = module.penp_labels
}
