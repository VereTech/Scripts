param(
$users = ""
)

$logfile = "$env:SystemDrive\VereTech\Log.txt"
$date = date
Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
Write-Output "$date : Starting 'ResetLocalAccountPassword.ps1'" | Out-File -Append $logfile
$pass = "Password1!"
$ExitCode = 0

if ($users -eq "") {

    Write-Output "You havn't given me any usernames to reset..." | Out-File -Append $logfile
    Write-Host "You havn't given me any usernames to reset..."
    Write-Output "$date : Try checking if any usernames are in the Parameters" | Out-File -Append $logfile
    Write-Host "Try checking if any usernames are in the Parameters"
    $ExitCode = 1001

} else {
    
    foreach($user in $users){
        Write-Output "$date : Reseting password for $user" | Out-File -Append $logfile
        $UserCount++
        
        $ResetPass = [ADSI]"WinNT://localhost/$user,user"
        $ResetPass.SetPassword($pass)
        $ResetPass.PasswordExpired = 1
        $ResetPass.SetInfo()

        $CheckExpire = [ADSI]"WinNT://localhost/$user,user"

        if ($ResetPass.PasswordExpired -eq 1) {

            Write-Output "$date : Password for '$user' has been reset and must be changed at next logon" | Out-File -Append $logfile
            Write-Host "Password for '$user' has been reset and must be changed at next logon"


        } else {

            Write-Output "Failed to reset password for $user" | Out-File -Append $logfile
            Write-Host "Failed to reset password for $user"
            $ExitCode = 1001

        }

    }

}