# plain values

output "name" {
  value       = local.context.name
  description = "Normalized name"
}

output "environment" {
  value       = local.context.environment
  description = "Normalized environment"
}

output "stage" {
  value       = local.context.stage
  description = "Normalized stage"
}

output "subscription_name" {
  description = "Azure subscription name"
  value       = local.context.subscription_name
}

output "subscription_name_short" {
  description = "Shortened Azure subscription name or acronym"
  value       = local.context.subscription_name_short
}

output "location" {
  value       = local.location
  description = "Normalized location"
}

output "location_raw" {
  value       = local.context.location
  description = "Location as it was set by the user"
}

output "cloud" {
  value       = local.context.cloud
  description = "Cloud name or acronym"
}

output "cluster_name" {
  value       = local.context.cluster_name
  description = "Normalized cluster_name"
}

output "delimiter" {
  value       = local.context.delimiter
  description = "Delimiter between elements when generating id's"
}

# complex

output "attributes" {
  value       = local.context.attributes
  description = "List of attributes"
}
output "att" {
  value       = join("%%%", local.default_context.attributes) != join("%%%", var.attributes)
  description = "List of attributes"
}

output "label_order" {
  value       = local.context.label_order
  description = "The naming order of the id output and Name tag"
}

output "tags" {
  value       = local.all_tags
  description = "Normalized Tag map, includes generated tags"
}


# generated

output "id" {
  value       = local.id
  description = "Disambiguated ID"
}

output "ids" {
  value       = local.ids
  description = "Disambiguated IDs"
}

output "id_with_suffix" {
  description = "Same as ID, but with suffix appended."
  value       = local.id_with_suffix
}

output "ids_with_suffix" {
  description = "Same as IDs, but with suffix appended."
  value       = local.ids_with_suffix
}

output "id_upper" {
  value       = upper(local.id)
  description = "Disambiguated ID"
}

output "id_for_az_storage_account" {
  value       = local.id_for_az_storage_account
  description = "Id transformed to match Azure storage account name requirements: /[a-z0-9]{3,24}/"
}

output "ids_for_az_storage_account" {
  value       = local.ids_for_az_storage_account
  description = "Ids transformed to match Azure storage account name requirements: /[a-z0-9]{3,24}/"
}

output "id_for_az_key_vault" {
  value       = local.id_for_az_key_vault
  description = "Id transformed to match Azure key vault name requirements: /[a-z0-9-]{3,24}/"
}

output "ids_for_az_key_vault" {
  value       = local.ids_for_az_key_vault
  description = "Ids transformed to match Azure key vault name requirements: /[a-z0-9-]{3,24}/"
}
# context

output "context" {
  value       = local.output_context_serialized
  description = "Context of this module to pass to other label modules"
}

output "context_raw" {
  value       = local.output_context_raw
  description = "Raw context of this module for debug purposes"
}

/*



output "fqdn" {
  value       = local.enabled ? local.fqdn : ""
  description = "fqdn, is useful when aux_domain is set"
}



output "tags_as_list_of_maps" {
  value       = local.tags_as_list_of_maps
  description = "Additional tags as a list of maps, which can be used in several AWS resources"
}



output "hostname_order" {
  value       = local.label_order_final_list
  description = "The naming order of the id output and Name tag"
}

*/
