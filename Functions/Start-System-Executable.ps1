<# 
  .SYNOPSIS 
  Starts a system process
  .DESCRIPTION
  Starts a system process
  .EXAMPLE
  
  .EXAMPLE
  Start-System-Executable -SystemApp "defrag" -Args "C:"
  .PARAMETER
  FilePath
  Mandatory
  The name of process that usually start when entered into CMD such as "defrag" or "ping"
  .PARAMETER
  ArgumentList
  Optional
  A string of arguments to send to process, for example "C:" or "localhost" or "/silent"
  #>
function Start-System-Executable {
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