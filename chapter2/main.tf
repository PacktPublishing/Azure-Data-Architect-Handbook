#specify the backend
terraform {
  backend "azurerm" {
    storage_account_name = "storagephswmdag"
    container_name       = "terraformstate"
    key                  = "prod.terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  # Configuration options
  skip_provider_registration = true
  features {

  }
}

#create a random string 
resource "random_string" "random" {
  length  = 5
  special = false
  number  = false
}

#Resource block
data "azurerm_resource_group" "rg_labs" {
  name = "rgTerraformLabs"
}


data "azurerm_storage_account" "str_StateStore" {
  name                = var.stateStore
  resource_group_name = data.azurerm_resource_group.rg_labs.name

  depends_on = [
    data.azurerm_resource_group.rg_labs
  ]

}

/*
data "azurerm_public_ip" "pip" {
  name                = "pipubuntuvm"
  resource_group_name = data.azurerm_resource_group.rg_labs.name

  depends_on = [
    data.azurerm_resource_group.rg_labs
  ]
}
*/

module "vnet" {
  source = "./Modules/Network/VirtualNetwork"
  depends_on = [
    module.nsg
  ]
  location        = var.location
  environment     = local.environment
  rg_name         = var.rg_name
  nsg_id          = module.nsg.id_out
  storage_account = data.azurerm_storage_account.str_StateStore.name
}


module "nsg" {
  source      = "./Modules/Network/NetworkSecurityGroup"
  location    = var.location
  environment = var.environment
  rg_name     = var.rg_name
  port        = 22
}


/*
module "vm" {
  source      = "./Modules/Compute/VirtualMachines"
  location    = var.location
  environment = local.environment
  rg_name     = var.rg_name
  vm_name     = var.vm_name
  subnet      = module.vnet.subnet_id
  password    = data.azurerm_key_vault_secret.main.value
  user        = local.vm.user_name
}
*/

locals {
  environment    = var.environment
  createeventhub = var.spinExtra
  /*
  vm = {
    computer_name = var.vm_name
    user_name     = "admin1234"
  }
 */
}



data "azurerm_key_vault_secret" "main" {
  name         = var.admin_pw_name
  key_vault_id = var.key_vault_resource_id
}


resource "azurerm_eventhub_namespace" "ehnamespace" {
  count               = local.createeventhub ? 1 : 0
  name                = "srramsampleeh"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg_labs.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = var.environment
  }
}

resource "azurerm_eventhub" "ehub1" {
  count               = local.createeventhub ? 1 : 0
  name                = "sourceeventhub"
  namespace_name      = azurerm_eventhub_namespace.ehnamespace[0].name
  resource_group_name = data.azurerm_resource_group.rg_labs.name
  partition_count     = 8
  message_retention   = 7
  depends_on = [
    azurerm_eventhub_namespace.ehnamespace
  ]
}


module "adf" {
  source                          = "./Modules/DataAnalytics/DataFactory"
  resource_group_name             = data.azurerm_resource_group.rg_labs.name
  location                        = var.location
  storage_account                 = data.azurerm_storage_account.str_StateStore.name
  managed_virtual_network_enabled = true
  adfname                         = format("%s%s", lower(random_string.random.result), "adf")
  principalname                   = var.principalName
  tags = {
    environment = local.environment
  }
}

module "synapse" {
  source                          = "./Modules/DataAnalytics/DW"
  environment_name                = local.environment
  resource_group_name             = data.azurerm_resource_group.rg_labs.name
  location                        = var.location
  storage_account                 = data.azurerm_storage_account.str_StateStore.name
  database_pools                  = var.databasePools
  managed_virtual_network_enabled = true
  syn_ws_name                     = var.synWsName
  secObj                          = var.synaddsecObj
  tags = {
    environment = local.environment
  }
  aad_admin = {
    login     = var.loginId
    object_id = var.objectId
    tenant_id = var.tenantId
  }
}

resource "azurerm_application_insights" "this" {
  name                = "workspace-example-ai"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg_labs.name
  application_type    = "web"
}

resource "azurerm_machine_learning_workspace" "this" {
  name                    = format("%s%s", lower(random_string.random.result), "mlws")
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.rg_labs.name
  application_insights_id = azurerm_application_insights.this.id
  key_vault_id            = var.key_vault_resource_id
  storage_account_id      = data.azurerm_storage_account.str_StateStore.id

  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = false
  image_build_compute_name      = var.image_build_compute_name
}

