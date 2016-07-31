<# 
  .SYNOPSIS 
  Describe the function here 
  .DESCRIPTION
  Describe the function in more detail
  .OUTPUT
  Describe the error levels and verboseness? <is that a word?> of the script
  .EXAMPLE 
  Give an example of how to use it 
  .EXAMPLE 
  Give another example of how to use it 
  .PARAMETER -paramname
  Describe the parameter here
  .PARAMETER
  Describe the parameter here
  .COMPATIBILITY
  Mark the archetecture of the OS the script has been tested on, for example if the 
  script works on both x64 and x86 versions of Windows 10, then; Windows 10 = x64, x86
  Windows 10     = 
  Server 2012 R2 = 
  Windows 8.1    = 
  Server 2012    = 
  Windows 8      = 
  Server 2008 R2 = 
  Windows 7      = 
  Server 2008    =
  Windows Vista  = 
  Server 2003 R2 =
  Windows XP     =  
  Server 2003    =
  #>
Param (
# List the scripts parameters here
)
#
# Setup, general configuration of script
#
    $Global:CompanyName = "VereTech"                    # The company name, this is the operating folder for all scripts, tools and packages, will be created under SYSTEMDRIVE
    $Global:ScriptName = "ResetLocalAccountPassword.ps1"                    # Title of the script, used for logging and script identification
    $Global:ScriptParameters = ""                    # List the scripts parameters here as variables such as $param0 $param1 $param2, if none, leave as ""

# Log file path
    $Global:LogFileName = "Log.txt"                    # Filename to save the logfile as, "Log.txt" for example
    $Global:CompanyFolder = "$env:SystemDrive\$Global:CompanyName"                    # 
    $Global:LogFullPath = $Global:CompanyFolder + "\" + $Global:LogFileName                    #

#
# Pre-flight checks
#
    # If no parameters have been given to script, then set this var to string 'NONE', used for logging
if (!($Global:ScriptParameters)) {
        $Global:ScriptParameters = "NONE"
    }

    # If company folder doesnt exist, warn and exit
if (!(Test-Path "$Global:CompanyFolder")) {
        Write-Warning "Need to run the RunOnce Script again, Company Folders do not exist."
        exit 1001
    }

#
# List functions here
#

Function Log-Start{
  <#
  .SYNOPSIS
    Use to start logging
  .DESCRIPTION
    Writes initial logging data
  .PARAMETER LogPath
    Uses global variables instead of parameters, the following globals must be set prior to starting function

    $Global:LogFileName = "Log.txt"
    $Global:LogFilePath = "C:\VereTech\Log.txt"

    $Global:LogFullPath = $Global:LogFilePath + "\" + $Global:LogFileName
    $Global:ScriptParameters = PC1 PC2

  .EXAMPLE
    Log-Start
  #>

  Process{
    $StartLine = [pscustomobject]@{
        'DATE TIME' = (Get-Date)
        'SCRIPT NAME' = "$Global:ScriptName"
        'STATUS' = "0"
        'CATAGORY' = "START"
        'MESSEGE' = "Starting with the following parameters : $Global:ScriptParameters"
        }

    $StartLine | Export-Csv -Path $Global:LogFullPath -Append -NoTypeInformation
    
    #Write to host for debug mode
    Write-Host (Get-Date) ": $Global:ScriptName : 0 : START : Starting script with the following parameters : $Global:ScriptParameters"
  }
}
Function Log-Write{
  <#
  .SYNOPSIS
    Writes to a log file
  .DESCRIPTION
    Appends a new line to the end of the specified log file
  
  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
  
  .PARAMETER LineValue
    Mandatory. The string that you want to write to the log
      
  .INPUTS
    Parameters above
  .OUTPUTS
    None
  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development
  
    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support
  .EXAMPLE
    Log-Write -LogPath "C:\Windows\Temp\Test_Script.log" -LineValue "This is a new line which I am appending to the end of the log file."
  #>
  
  [CmdletBinding()]
  
  Param (
  [Parameter(Mandatory=$false)][string]$Status = "0",
  [Parameter(Mandatory=$false)][string]$Catagory = "INFO",
  [Parameter(Mandatory=$true)][string]$Messege
  )
  
  Process{
    $WriteLine = [pscustomobject]@{
        'DATE TIME' = (Get-Date)
        'SCRIPT NAME' = "$Global:ScriptName"
        'STATUS' = "$Status"
        'CATAGORY' = "$Catagory"
        'MESSEGE' = "$Messege"
        }
    $WriteLine | Export-Csv -Path $Global:LogFullPath -Append -NoTypeInformation
      
    #Write to host for debug mode
    Write-Host (Get-Date) ": $Global:ScriptName : $Status : $Catagory : $Messege"
  }
}
Function Log-Error{
  <#
  .SYNOPSIS
    Writes an error to a log file
  .DESCRIPTION
    Writes the passed error to a new line at the end of the specified log file
  
  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write to. Example: C:\Windows\Temp\Test_Script.log
  
  .PARAMETER ErrorDesc
    Mandatory. The description of the error you want to pass (use $_.Exception)
  
  .PARAMETER ExitGracefully
    Mandatory. Boolean. If set to True, runs Log-Finish and then exits script
  .INPUTS
    Parameters above
  .OUTPUTS
    None
  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development
    
    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support. Added -ExitGracefully parameter functionality
  .EXAMPLE
    Log-Error -LogPath "C:\Windows\Temp\Test_Script.log" -ErrorDesc $_.Exception -ExitGracefully $True
  #>
  
  [CmdletBinding()]
  
  Param (
  [Parameter(Mandatory=$false)][string]$Status = "1001",
  [Parameter(Mandatory=$false)][string]$Catagory = "ERROR",
  [Parameter(Mandatory=$true)][string]$Messege
  )
  
  Process{
    $ErrorLine = [pscustomobject]@{
        'DATE TIME' = (Get-Date)
        'SCRIPT NAME' = "$Global:ScriptName"
        'STATUS' = "$Status"
        'CATAGORY' = "$Catagory"
        'MESSEGE' = "$Messege"
        }

    $ErrorLine | Export-Csv -Path $Global:LogFullPath -Append -NoTypeInformation
  
    #Write to screen for debug mode
    Write-Host (Get-Date) ": $Global:ScriptName : $Status : $Catagory : Error: An error has occurred [$Messege]."
        
    # call the Log-Finish and exit
    Log-Finish -status "$Status"
    exit 1001
    }
  }
Function Log-Finish{
  <#
  .SYNOPSIS
    Write closing logging data & exit
  .DESCRIPTION
    Writes finishing logging data to specified log and then exits the calling script
  
  .PARAMETER LogPath
    Mandatory. Full path of the log file you want to write finishing data to. Example: C:\Windows\Temp\Test_Script.log
  .PARAMETER NoExit
    Optional. If this is set to True, then the function will not exit the calling script, so that further execution can occur
  
  .INPUTS
    Parameters above
  .OUTPUTS
    None
  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  10/05/12
    Purpose/Change: Initial function development
    
    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  19/05/12
    Purpose/Change: Added debug mode support
  
    Version:        1.2
    Author:         Luca Sturlese
    Creation Date:  01/08/12
    Purpose/Change: Added option to not exit calling script if required (via optional parameter)
  .EXAMPLE
    Log-Finish -LogPath "C:\Windows\Temp\Test_Script.log"
.EXAMPLE
    Log-Finish -LogPath "C:\Windows\Temp\Test_Script.log" -NoExit $True
  #>
  param (
  [Parameter(Mandatory=$false)][string]$Status = "0"
  )
   
  Process{
    $FinishLine = [pscustomobject]@{
        'DATE TIME' = (Get-Date)
        'SCRIPT NAME' = "$Global:ScriptName"
        'STATUS' = "$Status"
        'CATAGORY' = "FINISH"
        'MESSEGE' = "Finished script"
        }

    $FinishLine | Export-Csv -Path $Global:LogFullPath -Append -NoTypeInformation
    #Write to host for debug mode
    Write-Host (Get-Date) ": $Global:ScriptName : $Status : FINISH : Finished scripts using the following parameters : $Global:ScriptParameters"
  
  }
}
function DetectOSVer {
<# 
  .SYNOPSIS 
  Detects OS Version
  .DESCRIPTION 
  Returns the operating system version as an array of strings
  example array:
  "Major" "Minor" "Build" "ServicePack" "Archetecture"
   10      0       10240   0             x64
   This will tell you that the OS is windows 10, no service pack is installed and is 64bit
  .EXAMPLE 
  $OSVersion = DetectOSVer
  .EXAMPLE
  This will show you the 5th element in the array which is the OS Archetecture.
  $OSVersion = DetectOSVer
  Write-Host $OSVersion[4]
  #>
Log-Write -Messege "DetectOSVer initiated"
Log-Write -Messege "Detecting Operating System Version..."
$OSMajor = [System.Environment]::OSVersion.Version.Major
$OSMinor = [System.Environment]::OSVersion.Version.Minor
$OSBuild = [System.Environment]::OSVersion.Version.Build
$OSSP = [System.Environment]::OSVersion.ServicePack
if ($OSSP -eq "") {
    Log-Write -Messege "Unable to detect what service pack is installed, setting value to 0"
    $OSSP = 0
}
Log-Write -Messege "Operating System Version is $OSMajor $OSMinor $OSBuild, With Service Pack $OSSP"
Log-Write -Messege "Detecting Operating System Archetecture..."

$CPUHash = @{0="x86";1="MIPS";2="Alpha";3="PowerPC";5="ARM";6="Itanium-based systems";9="x64"} 
$OutputObj = New-Object -TypeName PSobject 
$OutputObj  | Add-Member -MemberType NoteProperty -Name Architecture -Value "Unknown" 
$CPUObj = Get-WMIObject -Class Win32_Processor -EA Stop 
$CPUArchitecture = $CPUHash[[int]$CPUObj.Architecture] 
if($CPUArchitecture) { 
  $OutputObj.Architecture = $CPUArchitecture 
  $OSArch = "$CPUArchitecture"
} else { 
  $OSArch = $OutputObj.Architecture = ("Unknown`({0}`)" -f $CPUObj.Architecture)
}

Log-Write -Messege "Operating System Archetecture is $OSArch"
return ("$OSMajor","$OSMinor","$OSBuild","$OSSP","$OSArch")

}
function DownloadURL {
<# 
  .SYNOPSIS 
  Attempts to download a file from a URL using multiple different methods to get the job done
  .DESCRIPTION 
  It will return the full file path, C:\Path\to\file.exe if the download was successfull or if the file already exists. 
  if the file already exists it will also warn awell.
  If no filename was passed it will attempt to get filename from URL, if it cant it will return FALSE and error
  If the download to folder doesnt exist it will error
  .EXAMPLE 
  DownloadURL -URL "URL" -OutputFolder "OutputFolder" -OutputFile "OutputFile"
  .EXAMPLE 
  DownloadURL -URL "https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe" -OutputFolder "C:\VereTech\Tools" -OutputFile "putty.exe"
  .EXAMPLE
  This example shows that it is not nessesary to provide the Outputfile, this only works if the filename is included in the URL.
  DownloadURL -URL "https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe" -OutputFolder "C:\VereTech\Tools"
  .EXAMPLE
  This example shows that you only have to provide the URL to download a file, this comes with conditions,
  As stated above, the filename must be found somewhere in the URL and the default download path if one is not provided is
  Specified in the PARAM section as [string]$OutputFolder = "C:\ENTER\YOUR\DEFAULT\FOLDER",
  DownloadURL -URL "https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe"
  .PARAMETER URL
  The URL to download the file from 
  .PARAMETER OutputFolder
  The folder in which to store the downloaded file, NO DOT USE A SUFFIX "\" 
  .PARAMETER OutputFfile
  The file name in which to save the file as
  #> 
param(
[Parameter(Mandatory=$true)][string]$URL,
[string]$OutputFolder = "$Global:CompanyFolder",
[string]$OutputFile
)  

Log-Write -Messege "DownloadURL initiated"

if ($OutputFile -eq "") {
    Log-Write -Messege "No Filename passed to downloader, trying to get filename from URL = $URL"
    $OutputFile = [System.IO.Path]::GetFileName($URL)
    if ($OutputFile -eq "") {
        Log-Error -Messege "Cannot get Filename from URL = $URL"
        }
    }

If (!(Test-Path "$OutputFolder")) {
    Log-Write -Status "1" -Catagory "WARNING" -Messege "The Folder $OutputFolder does not exist, tring to create it now..."
    New-Item -Path "$OutputFolder" -ItemType "Directory"
    If (!(Test-Path "$OutputFolder")) {
        Log-Error -Messege "Cannot download $URL to $OutputFolder, cannot create the directory"
        }
    Log-Write -Messege "Successfully created $OutputFolder"
    }                                         

if ((Test-Path $OutputFolder\$OutputFile)) {
    Log-Write -Catagory "WARNING" -Status "1" "Cannot Download $URL, The folder $OutputFolder\$OutputFile already exists"
    Log-Write -Messege "I'm telling the operator to use that file instead of downloading it again"
    return "$OutputFolder\$OutputFile"                                                                
    }
 
if (!(Test-Path $OutputFolder\$OutputFile)) {
    Log-Write -Messege "Starting to download $URL using Method 1, Invoke-WebRequest"
    Invoke-WebRequest -Uri "$URL" -OutFile "$OutputFolder\$OutputFile"
    Log-Write -Messege "Finished trying to downloading $URL using Method 1"
    }
                        
if (!(Test-Path $OutputFolder\$OutputFile)) {
    Log-Write -status 1 -catagory "WARNING" -messege "File doesn't exist after using Method 1"
    Log-Write -Messege "Starting to download $URL using Method 2, .NET WebClient"
    New-Object System.Net.WebClient.DownloadFile("$URL", "$OutputFolder\$OutputFile")
    Log-Write -Messege "Finished trying to downloading $URL using Method 2"
    }

if (!(Test-Path $OutputFolder\$OutputFile)) {
    Log-Write -status 1 -catagory "WARNING" -messege "File doesn't exist after using Method 2"
    Log-Write -Messege "Starting to download $URL using Method 3, BITS"
    Import-Module BitsTransfer
    Start-BitsTransfer -Source "$URL" -Destination "$OutputFolder\$OutputFile"
    Log-Write -Messege "Finished trying to downloading $URL using Method 3"                    
    }

if ((Test-Path $OutputFolder\$OutputFile)) {
    Log-Write -Messege "Successfully Downloaded $URL to $OutputFolder\$OutputFile"
    return "$OutputFolder\$OutputFile"
} else {
    Log-Error -Messege "Failed to download $URL to $OutputFolder\$OutputFile"
    }
}
function Is-Installed( $IsApp ) {
<# 
  .SYNOPSIS 
  Search for installed Applications where the application name is "like" the passed parameter.
  This uses the registry to conduct its search instead of WMIC. 
  .DESCRIPTION 
  Set registry search folders based on systems Archetecture (64 or 32 bit)
  .EXAMPLE 
  Is-Installed "7-Zip"
  .EXAMPLE 
  Is-Installed "Acrobat"
  .PARAMETER IsApp
  The application name to search for. 
  #>
Log-Write -Messege "Is-Installed initiated"
Log-Write -Messege "Searching for installed applications where name is like : $IsApp"
$IsAppOSVer = DetectOSVer
if ($IsAppOSVer[4] -eq "x86") {
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
    Where-Object { $_.GetValue( "DisplayName" ) -like "*$IsApp*" } ).Length -gt 0;
    Log-Write -Messege "Did Is-Installed find '$IsApp' ? : $x86"
    }
if ($IsAppOSVer[4] -eq "x64") {
    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
    Where-Object { $_.GetValue( "DisplayName" ) -like "*$IsApp*" } ).Length -gt 0;
    Log-Write -Messege "Did Is-Installed find '$IsApp' ? : $x64"
    }

return $x86 -or $x64;
}
function Start-System-Executable {
<# 
  .SYNOPSIS 
  Starts a system process
  .DESCRIPTION
  Starts a system process, waits for it to finish, then dumps the output to console
  .EXAMPLE
  
  .EXAMPLE
  Start-System-Executable -SystemApp "defrag" -Args "C:"
  .PARAMETER
  FileName
  Mandatory
  The name of process that usually start when entered into CMD such as "defrag" or "ping"
  .PARAMETER
  ArgumentList
  Optional
  A string of arguments to send to process, for example "C:" or "localhost" or "/silent"
  #>
param(
[String] $FileName,
[String[]] $ArgumentList
)
Log-Write -Messege "Start-System-Executable initiated"
$OFS = " "
Log-Write -Messege "Building start information for process $FileName"
$process = New-Object System.Diagnostics.Process
$process.StartInfo.FileName = $FileName
$process.StartInfo.Arguments = $ArgumentList
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.RedirectStandardOutput = $true
if ( $process.Start() ) {
    Log-Write -Messege "Building console output redirection information for process $FileName"
    $output = $process.StandardOutput.ReadToEnd() `
    -replace "\r\n$",""
    if ( $output ) {
        if ( $output.Contains("`r`n") ) {
            $output -split "`r`n"
            } elseif ( $output.Contains("`n") ) {
                $output -split "`n"
            } else {
                $output
            }
        } else {
            Log-Error -Messege "Unable to build console output redirection information for process $FileName"
            }
    Log-Write -Messege "Starting system process '$FileName $ArgumentList'"
    $process.WaitForExit()
    & "$Env:SystemRoot\system32\cmd.exe" `
    /c exit $process.ExitCode
    $ec = $process.ExitCode
    if ($ec -gt 0) {
        Log-write -Status "$ec" -Catagory "WARNING" -Messege "Process $FileName ended unexpectedly"
        Log-Write -Status "$ec" -Catagory "CONSOLE" -Messege "$output"
        return $ec;
        } else {
            Log-Write -Messege "Process $FileName completed successfully"
            Log-Write -Status "$ec" -Catagory "CONSOLE" -Messege "$output"
            return $ec
            }
    } else {
        Log-Error -Messege "Unable to build start information for process $FileName"
        }
}
function Unzip {
<#
  .SYNOPSIS 
  Unzips a compressed ZIP file using bultin system
  .DESCRIPTION
  Unzips the passed file to the passed folder
  .EXAMPLE
  
  .EXAMPLE
  Start-System-Executable -SystemApp "defrag" -Args "C:"
  .PARAMETER
  ZipFile
  the full path to the zipped file you want to extract
  .PARAMETER
  XFolder
  the full folder path where you want to extract folder
  #>
param(
[string]$ZipFile, [string]$XFolder
)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $XFolder)
}


Try {
Log-Start
# Insert your script here
Log-Finish
}

Catch {
# Enter your catch here
}