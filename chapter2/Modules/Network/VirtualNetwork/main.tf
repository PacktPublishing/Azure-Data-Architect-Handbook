resource "azurerm_virtual_network" "main" {
  name                = "${var.environment}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
  subnet {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
    security_group = var.nsg_id
  }

}

resource "azurerm_subnet" "snet-workspace" {
  name                                           = "snet-workspace"
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.main.name
  address_prefixes                               = var.ml_subnet_address_space
  enforce_private_link_endpoint_network_policies = true
  depends_on = [
    azurerm_virtual_network.main
  ]
}


resource "azurerm_private_endpoint" "st_ple_blob" {
  name                = "ple-ml-${var.environment}-st-blob"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.snet-workspace.id

  /*
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsstorageblob.id]
  }
  */

  private_service_connection {
    name                           = "psc-${var.environment}-st"
    private_connection_resource_id = "/subscriptions/3d60da7d-bacf-4c0f-9333-16143cd9da70/resourceGroups/rgTerraformLabs/providers/Microsoft.Storage/storageAccounts/storagephswmdag"
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}


