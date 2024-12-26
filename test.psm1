###############################################################################
# sysadmin-toolbox module                                                     #
# Author
# Colby Bedell
#
###############################################################################


function Load-SysAdminToolBox { 
    param (
       [string]$path 
       
    )
    
}


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
    return $size
}


function STB-GetUsers {
    param (
        [OptionalParameters]
    )
    
}

