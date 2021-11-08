locals {

  output_context_raw        = { for k, v in local.context : k => v if k != "name" }
  output_context_serialized = base64encode(jsonencode(local.output_context_raw))

}
