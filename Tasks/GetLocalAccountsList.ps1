
<#
  .SYNOPSIS
  Report a list of local user accounts
  .DESCRIPTION
  Use by itself to obtain a list of the localhost
  .EXAMPLE
  Get-LocalAccountList
  #>
$ExitCode = "0"
$users = ""
$users = get-wmiobject win32_useraccount –computername $computer
    
if (!($users)) {

    Write-Host "Unable to obtain a list of local users for $computer"
        
    if ($ExitCode -eq "0") {

        $ExitCode = "1001"

    }
} else {

    foreach ($user in $users) {
    
        Write-Host $user.Name
        
    }

}


if ($ExitCode -eq "0") {

    exit 0

} else {

    Write-Host "Unable to obtain a list of local users"
    exit 1001

}

