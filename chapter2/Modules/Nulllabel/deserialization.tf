locals {

  # this map shall have a list of items that are required for the module to function
  default_context = {
    name                    = ""
    names                   = []
    environment             = ""
    stage                   = ""
    subscription_name       = ""
    subscription_name_short = ""
    location                = ""
    cloud                   = ""
    cluster_name            = ""
    delimiter               = "-"

    # this value must be the same as the one in variables.tf
    label_order = [
      "environment",
      "stage",
      "name",
      "attributes",
    ]

    generate_tags = {
      name         = "Name"
      environment  = "Environment"
      cluster_name = "ClusterName"
      stage        = "Stage"
    }

    # attributes are appended
    attributes = []

    # suffixes are merged
    suffixes = []

    # tags are merged
    tags = {}
  }

  input_context = merge(local.default_context, jsondecode(base64decode(var.context)))

  context = {
    name                    = var.name  # ignore name from input context
    names                   = var.names # ignore names from input context
    environment             = var.environment == local.default_context.environment ? local.input_context.environment : var.environment
    stage                   = var.stage == local.default_context.stage ? local.input_context.stage : var.stage
    subscription_name       = var.subscription_name == local.default_context.subscription_name ? local.input_context.subscription_name : var.subscription_name
    subscription_name_short = var.subscription_name_short == local.default_context.subscription_name_short ? local.input_context.subscription_name_short : var.subscription_name_short
    location                = var.location == local.default_context.location ? local.input_context.location : var.location
    cloud                   = var.cloud == local.default_context.cloud ? local.input_context.cloud : var.cloud
    cluster_name            = var.cluster_name == local.default_context.cluster_name ? local.input_context.cluster_name : var.cluster_name
    delimiter               = var.delimiter == local.default_context.delimiter ? local.input_context.delimiter : var.delimiter
    label_order             = join("%%%", local.default_context.label_order) == join("%%%", var.label_order) ? local.input_context.label_order : var.label_order
    attributes              = compact(concat(local.input_context.attributes, var.attributes))
    suffixes                = compact(concat(local.input_context.suffixes, var.suffixes))
    generate_tags           = base64encode(jsonencode(local.default_context.generate_tags)) == base64encode(jsonencode(var.generate_tags)) ? local.default_context.generate_tags : var.generate_tags
    tags                    = merge(local.default_context.tags, local.input_context.tags, var.tags)
  }
}
