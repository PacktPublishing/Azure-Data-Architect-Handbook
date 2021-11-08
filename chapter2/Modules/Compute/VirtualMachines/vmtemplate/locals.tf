module "labels" {
  source      = "../../../Nulllabel"
  context     = var.labels_context
  label_order = var.label_order
  name        = var.project_name
  attributes  = var.attributes
}

resource "random_password" "password" {
  for_each = local.vm_keys

  length      = 32
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 3
  number      = true
  min_numeric = 4
  special     = true
  min_special = 2
  keepers = {
    random_string = var.random_resource_trigger
  }
}

resource "random_string" "username" {
  for_each = local.vm_keys

  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true
  min_numeric = 2
  special     = false
  min_special = 0
  keepers = {
    random_string = var.random_resource_trigger
  }
}
