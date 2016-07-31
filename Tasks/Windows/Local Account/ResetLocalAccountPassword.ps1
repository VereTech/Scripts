param(
$users = ""
)
$Global:CompanyName = "VereTech"
$Global:ScriptName = "ResetLocalAccountPassword.ps1"
$Global:ScriptParameters = $users
$Global:LogFilePath = "$env:SystemDrive\$Global:CompanyName\Log.txt"

$pass = "Password1!"

function Write-Log
{
    param (
        [Parameter(Mandatory)]
        [string]$Message
        )
    
    $line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'Message' = $Message
        'Script Parameters' = $Global:ScriptParameters
    }
    
    ## Ensure that $LogFilePath is set to a global variable at the top of script
    $line | Export-Csv -Path $Global:LogFilePath -Append -NoTypeInformation
}


Write-Log "----------------------------------------------------------------------------------------------------"
Write-Log "'START'"
Write-Log "----------------------------------------------------------------------------------------------------"

Try {

# Setup VAR
$ExitCode = 0
$UserCount = 0
$ResetSuccess = 0

if ($users -eq "") {
    
    Write-Output "$date : $scriptname $scriptparameters : 'You havn't given me any usernames to reset...'" | Out-File -Append $logfile
    Write-Host "You havn't given me any usernames to reset..."
    Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
    Write-Output "$date : $scriptname $scriptparameters : 'FINISH' : 'FAIL'" | Out-File -Append $logfile
    Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
    exit 1001

} else {
    
    foreach($user in $users){

        Write-Output "$date : $scriptname $scriptparameters : 'Reseting password for $user'" | Out-File -Append $logfile
        Write-Host "$date : Reseting password for $user"
        $UserCount++
        
        $ResetPass = [ADSI]"WinNT://$env:COMPUTERNAME/$user"
        $ResetPass.SetPassword($pass)
        $ResetPass.PasswordExpired = 1
        $ResetPass.SetInfo()

        $CheckExpire = [ADSI]"WinNT://$env:COMPUTERNAME/$user"

        if ($ResetPass.PasswordExpired -eq 1) {

            Write-Output "$date : $scriptname : 'Password for '$user' has been reset and must be changed at next logon'" | Out-File -Append $logfile
            Write-Host "Password for '$user' has been reset and must be changed at next logon"
            $ResetSuccess++

        } else {

            
            Write-Output "$date : $scriptname : 'Failed to reset password for $user'" | Out-File -Append $logfile
            Write-Host "Failed to reset password for $user"
            
        }

    }
    
    Write-Output "$date : $scriptname $scriptparameters : '$ResetSuccess of $UserCount accounts reset'" | Out-File -Append $logfile
    Write-Host "$ResetSuccess of $UserCount accounts reset"

    if ($ResetSuccess -eq $UserCount) {

        Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
        Write-Output "$date : $scriptname $scriptparameters : 'FINISH' : 'PASS'" | Out-File -Append $logfile
        Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
        exit 0

    } else {

        Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
        Write-Output "$date : $scriptname $scriptparameters : 'FINISH' : 'FAIL'" | Out-File -Append $logfile
        Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
        exit 1001

    }
    

}
}

Catch {

Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
Write-Output "$date : $scriptname $scriptparameters : 'FINISH' : 'CATCH FAIL'" | Out-File -Append $logfile
Write-host "----------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
exit 1001

}