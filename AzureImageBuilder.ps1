######################################################
#
# Azure Image Builder Windows 10 Base Configuration
# June 2021
#
######################################################

# Remove Builtin Apps

Remove-WindowsCapability -online -name App.Support.ContactSupport~~~~0.0.1.0
#*********** Disable Powershell Version 2.0
Disable-WindowsOptionalFeature -online -FeatureName "MicrosoftWindowsPowerShellV2Root"

$AppsList = "Microsoft.Messaging","Microsoft.People","Microsoft.SkypeApp","microsoft.windowscommunicationsapps","Microsoft.Office.OneNote"

ForEach ($App in $AppsList) 
{ 
    $PackageFullName = (Get-AppxPackage $App).PackageFullName
    $ProPackageFullName = (Get-AppxProvisionedPackage -online | Where-Object {$_.Displayname -eq $App}).PackageName
        write-host $PackageFullName
        Write-Host $ProPackageFullName 
    if ($PackageFullName) 
    { 
        Write-Host "Removing Package: $App"
        remove-AppxPackage -package $PackageFullName 
    } 
    else 
    { 
        Write-Host "Unable to find package: $App" 
    } 
        if ($ProPackageFullName) 
    { 
        Write-Host "Removing Provisioned Package: $ProPackageFullName"
        Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName 
    } 
    else 
    { 
        Write-Host "Unable to find provisioned package: $App" 
    } 

}

######################################################

# Set Timezone

Set-Timezone -Id "Mountain Standard Time"
w32tm /resync /force

######################################################

# Create Temp Directory

$FilePath = "C:\temp"

If(!(Test-Path $FilePath))

    {
        New-Item -Path "C:\" -Name "temp" -ItemType "Directory" -Force
    }

 Else 

    {
    }

######################################################

# Install FSLogix

Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'C:\temp\fslogix.zip'
Start-Sleep -Seconds 10
Expand-Archive -Path 'C:\temp\fslogix.zip' -DestinationPath 'C:\temp\fslogix\'  -Force
Start-Process "C:\temp\fslogix\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/Install /quiet /norestart"
Start-Sleep -Seconds 10

######################################################

# Install ConfigMgr Client
Invoke-WebRequest -Uri 'https://github.com/ty-james/Azure-Image-Builder/blob/main/ccmsetup.exe?raw=true' -OutFile 'C:\temp\ccmsetup.exe'
Start-Sleep -Seconds 10
Start-Process "C:\temp\ccmsetup.exe" -ArgumentList "SMSSITECODE=AUTO SMSCACHSIZE=5120"
Start-Sleep -Seconds 10