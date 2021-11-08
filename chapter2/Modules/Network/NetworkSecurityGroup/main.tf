resource "azurerm_network_security_group" "nsg" {
  name                = "${var.environment}nsg"
  location            = var.location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "AllowSSHIn"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }

}
