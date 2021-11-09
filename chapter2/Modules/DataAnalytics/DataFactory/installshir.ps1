param([string]$path, [string]$authKey)
function InstallGw([string] $gwPath)
{
    #Uninstall the Gateway if it is already present
    UnInstallGw

    Write-Host "Installing the SHIR Software from the binary provided"

    Start-Process "msiexec.exe" "/i $path /quiet /passive" -Wait
    Start-Sleep -Seconds 45

    Write-Host "Installed SHIR Software on the Compute"
}

function RegisterGw([string] $key)
{
    #In order to register the GW we need a key and the nodename. 8060 for the node intercommunication in HA Mode
    Write-Host "Register the gateway with key: $key"
    & "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe" @("-EnableRemoteAccess", "8060")
    & "C:\Program Files\Microsoft Integration Runtime\5.0\Shared\dmgcmd.exe" @("-RegisterNewNode", "$key", "$env:COMPUTERNAME")
    Write-Host "Registered the SHIR with the Data Factory"
}


function UnInstallGw()
{
    Write-Host "UnInstalling the SHIR .........."
    [void](Get-WmiObject -Class Win32_Product -Filter "Name='Microsoft Integration Runtime'" -ComputerName $env:COMPUTERNAME).Uninstall()

}

function InputVal([string]$path, [string]$key)
{

    if ([string]::IsNullOrEmpty($path))
    {
        throw "Provide the Valid Path for the SHIR bits"
    }

    if ([string]::IsNullOrEmpty($key))
    {
        throw "No Auth Key to register"
    }
}

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Get Admin previleges to run this script!`nPlease re-run this script as Admin"
    Break
}

$path="https://download.microsoft.com/download/E/4/7/E4771905-1079-445B-8BF9-8A1A075D8A10/IntegrationRuntime_5.8.7856.3.msi"
$authKey="IR@b9fbe003-2127-4f57-8b58-4043a0211156@srramadf@ServiceEndpoint=srramadf.eastus2.datafactory.azure.net@YsmBkHRWE0P6dlh7mLPVFoMF5+eTUsSfqJ/rNFeNzqY="
InputVal $path $authKey
InstallGw $path
RegisterGw $authKey 