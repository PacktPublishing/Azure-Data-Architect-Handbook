locals {
  # hardcode this, because data source does not work correctly
  # retry after https://github.com/terraform-providers/terraform-provider-azurerm/issues/6254
  azurerm_adf_monitor_diagnostic_categories = {
    logs = [
      "ActivityRuns",
      "PipelineRuns",
      "TriggerRuns",
      "SandboxActivityRuns",
      "SandboxPipelineRuns",
      "SSISPackageEventMessages",
      "SSISPackageEventMessageContext",
      "SSISPackageExecutableStatistics",
      "SSISPackageExecutionComponentPhases",
      "SSISPackageExecutionDataStatistics",
      "SSISIntegrationRuntimeLogs",
    ]
    metrics = ["AllMetrics"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = join("-", compact(["adf", module.labels.environment, module.labels.name, "diag"]))
  target_resource_id             = azurerm_data_factory.this.id
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = toset(local.azurerm_adf_monitor_diagnostic_categories.logs)
    content {
      category = log.key
      enabled  = var.logs.enabled

      retention_policy {
        enabled = true
        days    = var.logs.retention_days
      }
    }
  }

  dynamic "metric" {
    for_each = toset(local.azurerm_adf_monitor_diagnostic_categories.metrics)
    content {
      category = metric.key
      enabled  = var.metrics.enabled

      retention_policy {
        enabled = true
        days    = var.metrics.retention_days
      }
    }
  }
}
