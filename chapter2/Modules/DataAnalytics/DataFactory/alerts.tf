resource "azurerm_monitor_metric_alert" "this" {
  for_each             = var.alerts
  name                 = module.labels.ids_with_suffix[each.key].alert
  resource_group_name  = var.resource_group_name
  enabled              = each.value.enabled
  auto_mitigate        = each.value.auto_mitigate
  description          = each.value.description
  frequency            = each.value.frequency
  severity             = each.value.severity
  target_resource_type = "Microsoft.DataFactory/factories"
  window_size          = each.value.window_size
  tags                 = module.labels.tags

  scopes = [
    azurerm_data_factory.this.id
  ]

  dynamic "action" {
    for_each = try(each.value.action, [])
    content {
      action_group_id    = action.value.group_id
      webhook_properties = try(action.value.webhook_properties, null)
    }
  }

  dynamic "criteria" {
    for_each = try(each.value.criteria, [])
    content {
      metric_namespace = criteria.value.metric_namespace
      metric_name      = criteria.value.metric_name
      aggregation      = criteria.value.aggregation
      operator         = criteria.value.operator
      threshold        = criteria.value.threshold

      dynamic "dimension" {
        for_each = try(criteria.value.dimension, [])
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

}

