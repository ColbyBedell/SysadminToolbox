###############################################################################
# sysadmin-toolbox module                                                     #
# Author
# Colby Bedell
#
###############################################################################


function Setup-STBToolbox { 
    param (
    #  [parameter][string]$configFile 
       
    )
   $configFile = "C:\temp\SysAdminToolBox\config.json"
   if (Test-Path $configFile) {
        Write-Output "Config File Found."
        Write-Information "Loading Config File"
        $config = Get-Content $configFile | ConvertFrom-Json
        return $config
    }
    else {
        Write-Output "No Config File Found."
        Write-Information "Creating Config File"
        $config = @{}
        $config | Add-Member -MemberType NoteProperty -Name "ADType" -Value "OnPrem"
        $config | Add-Member -MemberType NoteProperty -Name "ExportDIR" -Value "C:\temp\SysAdminToolBox"
        $config | ConvertTo-Json | Out-File -FilePath $configFile
    } 
    
}
#Importing of the Configuration file for Global Variable use
$GlobalConfig = Get-Content "C:\temp\SysAdminToolBox\config.json" | ConvertFrom-Json

function STB-Getfilehash {
    param (
        [string]$path
    )
    $hash = Get-FileHash -Path $path -Algorithm SHA256
    return $hash
}

function STB-GetFileSize {
    param (
        [string]$path
    )
    $size = (Get-Item $path).length
    return $size }

function STB-LocUserinCSV {
    # This function will take a list of users and search for a specific user. 
    # The VariabletoFind is the column name in the CSV file that you want to search for the user in.
    param (
        [parameter(ValueFromPipeline = $true, Mandatory = $true)][string]$username,
        [parameter(ValueFromPipeline = $true, Mandatory = $true)][string]$pathToList,
        [parameter(ValueFromPipeline = $true, Mandatory = $true)][string]$VariabletoFind
    )
   Import-Csv $pathToList | Where-Object { $_.$($VariabletoFind) -eq $username }
}


function STB-LocUserinObject {
    # This function will take a list of users and search for a specific user. 
    # The VariabletoFind is the column name in the CSV file that you want to search for the user in.
    param (
        [parameter(ValueFromPipeline = $true, Mandatory = $true)][string]$username,
        [parameter(ValueFromPipeline = $true, Mandatory = $true)][object]$object,
        [parameter(ValueFromPipeline = $true, Mandatory = $true)][string]$VariabletoFind,
        [parameter(ValueFromPipeline = $true)][switch]$Export
    )
    $currentDate = Get-Date -Format "MM-dd"
    $ExportDirectory = "C:\temp\SysAdminToolBox"
    $object | Where-Object { $_.$($VariabletoFind) -eq $username }
    if ($Export.IsPresent) {
       if (!(Test-Path $ExportDirectory)) {
           New-Item -ItemType Directory -Path $ExportDirectory
        
    }
$object | Where-Object { $_.$($VariabletoFind) -eq $username } | Export-Csv -Path "$($ExportDirectory)/$($currentDate)STBToolBoxUserLoc.csv"
}
}


function STB-UpdateModule {

    $gitRepo = "https://raw.githubusercontent.com/ColbyBedell/SysadminToolbox/refs/heads/master/SysAdminToolBox.psm1"
    $ModulePath = $env:PSModulePath -split ';'
    
    $downloadedVersion = Invoke-WebRequest -Uri $gitRepo -OutFile $ModulePath[0] 

    try {
        Remove-Module SysAdminToolBox
        Import-Module "$($modulepath[0])\Sysadmintoolbox.psm1"

   }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
    finally {
        Write-Host "Module Updated"
    }


}

#Make a configuration file during setup of the module to switch from OnPrem AD to Entra ID


function STB-GetUsersGroups {
    param (
        [parameter (ValueFromPipeline = $true)][string]$username,
        [parameter][string]$GlobalConfig,
        [parameter (ValueFromPipeline = $true)][switch]$Export

    )

    if ($GlobalConfig.ADType -eq "OnPrem") {
        $user = Get-ADUser -Identity $username
        return $user
    }
    elseif ($GlobalConfig.ADType -eq "EntraID") {
        $user = Get-MGuser -Identity $username
        return $user
    }
   if ($Export.IsPresent) {
       $user | Export-Csv -Path "C:\temp\SysAdminToolBox\$($username)User.csv"
}
}
# Auto Check for updated from Git repo
