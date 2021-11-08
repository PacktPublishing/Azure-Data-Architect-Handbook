# Terraform template for a sample data environment

    - Example of a sample data landing zone that creates a fully functional data and ai environment for doing POCs with customer's sample data and run in a non production like environment
    - To make this an MVP and move data over complex network routes which is more common to prove end to end scenarios Data/AI CSAs should work with customer's infra-structure and the network team

## Pre-Requisites

    1. Create a resource Group
    2. Create a key Vault and have the Resource ID ready
    3. Create an Azure Storage Account. This storage account also serves as the Terraform state store
    4. A service principal, Secret and the Tenant ID with a permission of the Owner on the subscription
    5. To get maximum benifit customer could port their data from on-prem into the blob storage they created in step3

### All you need to do is change the inputs.tfvars and run three terraform commands to get your environment set up

***
    tagEnvironment        
        : supply the value for tags eg - "dev"
    stateStore  
        : A Storage account for state storage eg - storagephswmdag

    key_vault_name       
        : Name of your keyvault

    key_vault_resource_id 
        : Resource ID of your key vault eg - "/subscriptions/3d60da7d-********/resourceGroups/rgTerraformLabs/providers/Microsoft.KeyVault/vaults/********"

    location              
        : Location where your resources are spun up eg - "eastus"

    environment           
        : Environment name

    rg_name               
        : Resource Group Name
    
    spinExtra              
        : Some Extra resources such as eh are spun if set to true 

    loginId          
        : Application ID of the service principal
    
    objectId             
        : SP Object ID of app registration
    
    tenantId            
        : Tenant ID
    
    principalName        
        : Object ID of the Enterprise app corresponding to SP

    synWsName             
        : Synapse workspace name
    - synaddsecObj   
        : Te list of security groups, userids, managed identities etc that needs access to the synapse workspace      eg : "dc12d588-416e-46dc-897a-d40636c9dc4e","867baad1-f334-4216-9907-f946ef3198d2","e0ae2d70-3318-40bc-897b-e2a4ad85bd8f"]

### Install the Terraform and run the following Terraform Commands

    * Set the following mandatory variables in the local env
      ARM_CLIENT_ID: 
      ARM_CLIENT_SECRET: 
      ARM_SUBSCRIPTION_ID: 
      ARM_TENANT_ID: 
    * In your bash shell run the following
        1. terraform init -reconfigure
        2. terraform fmt 
        3. terraform plan -var-file ./inputs.tfvars -out LabPlan
        4. terraform apply -auto-approve LabPlan

#### For the Advanced users a sample github action is also incorporated
