/*
 *  We Use keys for for_each to satisfy requirements where for_each need to know at least keys
 *  while values can be calculated later during plan execution
 *  so we use for_each with key maps only and then referencing to map with values
 */
resource "azurerm_network_interface" "this" {
  for_each = local.vm_nic_keys

  name                          = local.vm_nic[each.key].name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  dns_servers                   = local.vm_nic[each.key].dns_servers
  enable_ip_forwarding          = local.vm_nic[each.key].enable_ip_forwarding
  enable_accelerated_networking = local.vm_nic[each.key].enable_accelerated_networking


  ip_configuration {
    name                          = format("ip-config-%s", local.vm_nic[each.key].id)
    primary                       = local.vm_nic[each.key].primary
    subnet_id                     = local.vm_nic[each.key].subnet_id
    private_ip_address_version    = local.vm_nic[each.key].private_ip_address_version
    private_ip_address_allocation = local.vm_nic[each.key].private_ip_address_allocation
    public_ip_address_id          = local.vm_nic[each.key].public_ip_address_id
    private_ip_address            = local.vm_nic[each.key].private_ip_address
  }

  tags = merge(module.labels.tags, var.tags, { project-name = var.project_name })
}

# Load Balancer Configuration
# https://www.terraform.io/docs/providers/azurerm/r/network_interface_backend_address_pool_association.html
resource "azurerm_network_interface_backend_address_pool_association" "nic" {
  # To satisfy for_rach we provide known keys but no real values
  for_each = ({
    for k, v in local.vm_nic_keys :
    k => v
    if v.lb_enabled
  })

  depends_on = [azurerm_network_interface.this]

  network_interface_id    = azurerm_network_interface.this[each.key].id
  ip_configuration_name   = format("ip-config-%s", local.vm_nic[each.key].id)
  backend_address_pool_id = local.vm_nic[each.key].lb_pool
}

# Application Gateway Configuration
# https://www.terraform.io/docs/providers/azurerm/r/network_interface_backend_address_pool_association.html
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic" {
  for_each = ({
    for k, v in local.vm_nic_keys :
    k => v
    if v.app_gw_enabled
  })

  depends_on = [azurerm_network_interface.this]

  network_interface_id    = azurerm_network_interface.this[each.key].id
  ip_configuration_name   = format("ip-config-%s", local.vm_nic[each.key].id)
  backend_address_pool_id = local.vm_nic[each.key].app_gw_pool
}
