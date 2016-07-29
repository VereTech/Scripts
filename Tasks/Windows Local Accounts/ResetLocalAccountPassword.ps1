param(
$users = ""
)

$pass = "Password1!"

$ExitCode = 0

if ($users -eq "") {

    Write-Host "You havn't given me any usernames to reset..."
    Write-Host "Try checking if any usernames are in the Parameters"
    $ExitCode = 1001

} else {
    
    foreach($user in $users){

        $UserCount++
        
        $ResetPass = [ADSI]"WinNT://localhost/$user,user"
        $ResetPass.SetPassword($pass)
        $ResetPass.PasswordExpired = 1
        $ResetPass.SetInfo()

        $CheckExpire = [ADSI]"WinNT://localhost/$user,user"

        if ($ResetPass.PasswordExpired -eq 1) {

            Write-Host "Password for '$user' is now '$pass'"


        } else {

            Write-Host "Failed to reset password for $user"
            $ExitCode = 1001

        }

    }

}