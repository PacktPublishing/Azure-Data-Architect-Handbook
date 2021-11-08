$storage = Get-AzStorageAccount -ResourceGroupName "rgTerraformLabs"
$storagekey = Get-AzStorageAccountKey -Name $storage.StorageAccountName -ResourceGroupName $storage.ResourceGroupName
$context = New-AzStorageContext -StorageAccountName $storage.StorageAccountName -StorageAccountKey $storagekey[0].Value
New-AzStorageContainer -Name "terraformstate" -Context $context
$id = $storage.StorageAccountName.Substring(9)
$vault = New-AzKeyVault -Name "vault-$id" -ResourceGroupName $storage.ResourceGroupName -Location EastUs
$secret = ConvertTo-SecureString -String $storagekey[0].Value -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $vault.VaultName -SecretValue $secret -Name 'Terraform'
