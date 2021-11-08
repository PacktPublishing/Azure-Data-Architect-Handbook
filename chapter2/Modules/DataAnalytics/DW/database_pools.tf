
locals {
  sql  = { for n, c in var.database_pools : n => c if try(c.type, "sql") == "sql"}
  spark = { for n, c in var.database_pools : n => c if try(c.type, "spark") == "spark" }
}

# Create Synapse sql pool
resource "azurerm_synapse_sql_pool" "this" {
  for_each              = local.sql
  name                  = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.ws.id
  sku_name             = each.value.sku_name
  create_mode          = each.value.create_mode
}

# Create spark  pool
resource "azurerm_synapse_spark_pool" "this" {
  for_each             = local.spark
  name                 = each.value.name
  synapse_workspace_id = azurerm_synapse_workspace.ws.id
  
  node_size_family     = var.node_size_family
  node_size            = var.node_size

  auto_scale {
    max_node_count = var.max_node_count
    min_node_count = var.min_node_count
  }

  auto_pause {
    delay_in_minutes = 15
  }

  tags = var.tags
}