output "sql_admin" {
  description = "SQL adminstrative user credentials"
  value = {
    username = var.sql_administrator_login
    password = random_password.sql_administrator.result
  }
}

output "id" {
  description = "Synapse Workspace ID."
  value       = azurerm_synapse_workspace.ws.id
}


output "localsql" {
    description = "local sql value"
    value={ for n, c in var.database_pools : n => c if try(c.type, "sql") == "sql"}
}