locals {

  id = lower(join(
    local.context.delimiter,
    compact(
      flatten([
        for label in local.context.label_order :
        local.context[label] if contains(keys(local.context), label)
      ]),
    )
  ))

  # double join-compact-flatten is required if an attribute is a list of strings
  # which has to be converted to a string for the template
  ids = { for n in local.context.names :
    n => lower(join(
      local.context.delimiter,
      compact(
        flatten([
          for label in local.context.label_order :
          "%{if label == "name"}${n}%{else}${join(local.context.delimiter, compact(flatten([local.context[label]])))}%{endif}"
          # local.context[label] if contains(keys(local.context), label)
        ]),
      )
    ))
  }

  ids_with_suffix = { for n in local.context.names :
    n => {
      for k in local.context.suffixes :
      k => format("%s%s%s", local.ids[n], local.context.delimiter, k)...
    }...
  }

  # Id transformed to match Azure storage account name requirements: /[a-z0-9]{3,24}/
  # name must be globally unique.
  id_for_az_storage_account = format("%s%s", var.storage_account_prefix, substr(sha256(local.id), 0, 24 - length(var.storage_account_prefix)))

  ids_for_az_storage_account = {
    for n in local.context.names :
    n => format("st%s", substr(sha256(local.ids[n]), 0, 22))
  }

  # Id transformed to match Azure key_vault name requirements: /[a-z0-9]{3,24}/
  # name must be globally unique.
  id_for_az_key_vault = format("%s%s", var.key_vault_prefix, substr(sha256(local.id), 0, 23 - length(var.key_vault_prefix)))

  ids_for_az_key_vault = {
    for n in local.context.names :
    n => format("%s%s", var.key_vault_prefix, substr(sha256(local.ids[n]), 0, 23 - length(var.key_vault_prefix)))
  }

  id_with_suffix = {
    for k in local.context.suffixes :
    k => format("%s%s%s", local.id, local.context.delimiter, k)...
  }

  generated_tags = {
    for k, v in local.context.generate_tags :
    v => local.context[k]
    if local.context[k] != ""
  }

  all_tags = merge(local.context.tags, local.generated_tags)

  tags_as_list_of_maps = [for k, v in local.all_tags : { "key" = k, "value" = v }]

  # This should end up in context, but since TNT is the weird one, lets keep it here
  # for now and see how it evolves.
  region_map = {
    neur = "northeurope"
    weur = "westeurope"
  }

  location = contains(keys(local.region_map), local.context.location) ? local.region_map[local.context.location] : local.context.location

}
