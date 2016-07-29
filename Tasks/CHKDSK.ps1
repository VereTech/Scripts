<# 
  .SYNOPSIS 
  Runs CHKDSK on all volumes
  .DESCRIPTION
  Can be used by itself or specify the drives by passing parameters.
  .EXAMPLE
  Specify to chkdsk 1 drive
  chkdsk.ps1 -Drives C:
  .EXAMPLE
  Specify to defrag multiple drives
  chkdsk.ps1 -Drives C:,D:,E:
  .PARAMETER
  -Drives
  Optional
  An array of drive letters to be checked else check the lot
  #>
param(
[string]$Drives

)

<# 
  .SYNOPSIS 
  Starts a system process
  .DESCRIPTION
  Starts a system process
  .EXAMPLE
  
  .EXAMPLE
  SystemProcess -SystemApp "defrag" -Args "C:"
  .PARAMETER
  SystemApp
  Mandatory
  The name of process that usually start when entered into CMD such as "defrag" or "ping"
  .PARAMETER
  Args
  Optional
  A string of arguments to send to process, for example "C:" or "localhost" or "/silent"
  #>
function Start-Executable {
                                param(
                                  [String] $FilePath,
                                  [String[]] $ArgumentList
                                )
                                $OFS = " "
                                $process = New-Object System.Diagnostics.Process
                                $process.StartInfo.FileName = $FilePath
                                $process.StartInfo.Arguments = $ArgumentList
                                $process.StartInfo.UseShellExecute = $false
                                $process.StartInfo.RedirectStandardOutput = $true
                                if ( $process.Start() ) {
                                  $output = $process.StandardOutput.ReadToEnd() `
                                    -replace "\r\n$",""
                                  if ( $output ) {
                                    if ( $output.Contains("`r`n") ) {
                                      $output -split "`r`n"
                                    }
                                    elseif ( $output.Contains("`n") ) {
                                      $output -split "`n"
                                    }
                                    else {
                                      $output
                                    }
                                  }
                                  $process.WaitForExit()
                                  & "$Env:SystemRoot\system32\cmd.exe" `
                                    /c exit $process.ExitCode
                                }
                              }

Try {
if ($Drives -eq "") {

    $Drives = get-wmiobject win32_logicaldisk -filter "drivetype=3" | select-object -expandproperty name

}

$DriveNumber = 0
$DrivesChecked = 0
foreach ($Drive in $Drives) {

    $DriveNumber++
    $process = Start-Executable "chkdsk" "$drive /r /x"


}

Write-Host "CHKDSK of $DriveNumber Drives Complete"
exit 0

} # End Try





Catch {

Write-Host "CHKDSK Failed"
exit 1001

} # End Catch
