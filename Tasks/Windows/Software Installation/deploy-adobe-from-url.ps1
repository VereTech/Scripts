<# 
  .SYNOPSIS 
  Download and install software from a URL depending on OS version and archetecture.
  .DESCRIPTION 
  This script can be launched with no parameters, however you can customise it by
  passing parameters to it, see the PARAMETERS section for details
  #>
#
# Parameters
#
param (
[string]$CompanyFolderName = "VereTech",                                   # Folder to execute "Setup Folder" in the systems drive.
[string]$PackageFolder = "$env:Systemdrive\$CompanyFolderName\Packages",   # Folder to download installer file
[string]$EXESwitches = "/msi EULA_ACCEPT=YES /qn /norestart /log $env:systemdrive\$CompanyFolderName\log.txt",              # Switches to pass to installer file if EXE
[string]$MSISwitches = "",                                                 # Switches to pass to installer file if MSI
[string]$MSPSwitches = ""                                                  # Switches to pass to installer file if MSP
)



#
# SETUP
# 

# Enter OS specific URL's here.
$URL = @{
    "5 . 0 . x86"=""          # Windows 2000
    "5 . 1 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe";          # Windows XP x86
    "5 . 2 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe";          # Server 2003 x86 + Server 2003 R2 x86
    "5 . 2 . x64"="http://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe";          # Windows XP x64 + Server 2003 x64 + Server 2003 R2 x64
    "6 . 0 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe";          # Vista x86 + Server 2008 x86
    "6 . 0 . x64"="http://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe";          # Vista x64 + Server 2008 x64
    "6 . 1 . x64"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 7 x64 + Server 2008 R2
    "6 . 1 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 7 x86
    "6 . 2 . x64"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 8 x64 + Windows Server 2012
    "6 . 2 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 8 x86
    "6 . 3 . x64"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 8.1 x64 + Windows Server 2012 R2
    "6 . 3 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/11.x/11.0.10/en_US/AdbeRdr11010_en_US.exe";          # Windows 8.1 x86
    "10 . 0 . x86"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 10 x86
    "10 . 0 . x64"="http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1501720050/AcroRdrDC1501720050_en_US.exe";          # Windows 10 x64 + Server 2016
    }



#
# Functions
#

<# 
  .SYNOPSIS 
  Setups folder Sctructure under C:\                   \    VereTech             \    Tools   
                                 $CompanyFolderDrive   \    $CompanyFolderName   \    $CompanySubFolders

  .DESCRIPTION 
  Sub folders can be entered with a "\" to create further sub folders, for example "Tools\Putty"
  .EXAMPLE 
  FolderSetup -CompanyFolderName "VereTech"
  #> 
function FolderSetup {
#
# Parameters
#
param(
[string]$CompanyFolderName
)

#
# SETUP
#
$CompanySubFolders = @(
    "Tools",
    "Scripts",
    "Packages"
)

$CompanyFolderDrive = $env:SystemDrive

#
# Execute
#
if ($CompanyFolderName -eq "") {

    Write-Warning "Please pass the Root folder name using parameter -CompanyFolderName"
    return "FALSE"

}

foreach ($CompanySubFolder in $CompanySubFolders) {
    if (!(Test-Path "$CompanyFolderDrive\$CompanyFolderName\$CompanySubFolder")) {
        New-Item -Path "$CompanyFolderDrive\$CompanyFolderName\$CompanySubFolder" -ItemType Directory|Out-Null
    }
}
$FolderCount = 0
foreach ($CompanySubFolder in $CompanySubFolders) {
    $FolderCount++
}


$FolderCountSuccess = 0
foreach ($CompanySubFolder in $CompanySubFolders) {
    if (Test-Path "$CompanyFolderDrive\$CompanyFolderName\$CompanySubFolder") {
        $FolderCountSuccess++
    }
}
if ("$FolderCountSuccess" -eq "$FolderCount") {

    return "TRUE"

} else {
    
    return "FALSE"

}

} # End Function
<# 
  .SYNOPSIS 
  Detects OS Version
  .DESCRIPTION 
  Returns the operating system version as an array of strings
  example array:
  "Major" "Minor" "Build" "ServicePack" "Is OS x64?"
   10      0       10240   0             True
   This will tell you that the OS is windows 10, no service pack is installed and is 64bit
  .EXAMPLE 
  $OSVersion = DetectOSVer
  .EXAMPLE
  This will show you the 5th element in the array which is the OS Archetecture.
  $OSVersion = DetectOSVer
  Write-Host $OSVersion[4]
  #>
function DetectOSVer {
$OSMajor = [System.Environment]::OSVersion.Version.Major
$OSMinor = [System.Environment]::OSVersion.Version.Minor
$OSBuild = [System.Environment]::OSVersion.Version.Build
$OSSP = [System.Environment]::OSVersion.ServicePack
if ($OSSP -eq "") {
    $OSSP = 0
}

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
 
return ("$OSMajor","$OSMinor","$OSBuild","$OSSP","$OSArch")
} # End Function
<# 
  .SYNOPSIS 
  Attempts to download a file from a URL using multiple different methods to get the job done
  If passed with the filename, it will save the file using that name, if not will attempt to get filename from URL passed
  .DESCRIPTION 
  If the files download folder destionation doesnt exist, THROW
  If the file already exists, THROW
  If the file doesnt exist on the system, download it using 3 different methods, testing the if the file exists before each attempt.
  After the download attempt run it check if the file exists, if it does it return TRUE, if it doesnt it will THROW
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
function DownloadURL {
param(
[Parameter(Mandatory=$true)]
[string]$URL,
[string]$OutputFolder = "$env:SystemDrive\VereTech",
[string]$OutputFile
)  

if ($OutputFile -eq "") {
    $OutputFile = [System.IO.Path]::GetFileName($URL)
}          # If no Filename given, try and get it from given URL

if ($OutputFile -eq "") {
    Write-Warning "DownloadURL: Cannot get Filename from $URL, please provide one using -OutputFile Filename.zip"
    return "FALSE"
}          # If cannot get filename from URL, Write-Error

If (!(Test-Path "$Outputfolder")) {

    Write-Warning "DownloadURL: The Folder $OutputFolder does not exist"
    return "FALSE"

 }          # If Download folder doesnt exist, Write-Error                                            

if ((Test-Path $OutputFolder\$OutputFile)) {
                                                              
    Write-Warning "DownloadURL: Cannot Download, $OutputFolder\$OutputFile already exists"
    return "$OutputFolder\$OutputFile"
                                                                
}          # If file already exists, Write-Warning
 
if (!(Test-Path $OutputFolder\$OutputFile)) {
    
    Write-Host "DownloadURL: Starting to download $URL using Method 1"
    Invoke-WebRequest -Uri "$URL" -OutFile "$OutputFolder\$OutputFile"
}         # If file doesnt exist, Try Download Method 1
                        
if (!(Test-Path $OutputFolder\$OutputFile)) {
        
        Write-Host "DownloadURL: Starting to download $URL using Method 2"
        New-Object System.Net.WebClient.DownloadFile("$URL", "$OutputFolder\$OutputFile")
             
}         # If file doesnt exist, Try Download Method 2

if (!(Test-Path $OutputFolder\$OutputFile)) {
        
        Write-Host "DownloadURL: Starting to download $URL using Method 3"                                              
        Import-Module BitsTransfer
        Start-BitsTransfer -Source "$URL" -Destination "$OutputFolder\$OutputFile"
                    
}         # If file doesnt exist, Try Download Method 3

if ((Test-Path $OutputFolder\$OutputFile)) {
    Write-Host "Download Successfull"
    return "$OutputFolder\$OutputFile"
} else {
    Write-Warning "Download failed"
    return "FALSE"
}          # If file exists return the full file path, if file still doesnt exist, Write-Error



} # End Function



#
# Execute Script
#

Try {

# Run Pre-Reqs
$OSVer = DetectOSver
$FolderSetup = FolderSetup -CompanyFolderName "$CompanyFolderName" |Out-Null


# Null future used values
$InstallFile = $null
$InstallFileExt = $null
$v0 = $null
$v1 = $null
$v4 = $null
$v = $null
$vURL = $null

# Get OS Version in a specific format
$v0 = $OSVer[0]
$v1 = $OSVer[1]
$v4 = $OSver[4]
$v = "$v0 . $v1 . $v4"
$vURL = $URL[$v]

# Fail Script for some conditions
if ($v -eq "") {
    
    Write-Host "Cannot detect operating system version"
    exit 1001

} elseif ($vURL -eq "") {

    Write-Host "OS not supported, URL not specified"
    exit 1001

}

# Set Download URL
$InstallFile = DownloadURL -URL "$vURL" -OutputFolder "$PackageFolder"   
       
if ($InstallFile -eq "FALSE") {

    Write-Host "Download Failed"
    exit 1001

}
# Get file extension that is thrown back from the DownloadURL function and place the filename extension into a variable, which by setting this variable initiates the download.
$InstallFileExt = [System.IO.Path]::GetExtension("$InstallFile")

# Start the install process
if ($InstallFileExt -eq ".exe") {

    $StartInstall = Start-Process $InstallFile $EXESwitches -PassThru -Wait
    
    if ($StartInstall.ExitCode -eq "0") {

        Write-Host "Installation completed successfully"
        exit 0

    } elseif ($StartInstall.ExitCode -ge "1") {

        Write-Host "Installation of $InstallFile failed"
        exit 1001

    }

} # If the Downloaded file is exe

if ($InstallFileExt -eq ".msi") {

    $StartInstall = Start-Process msiexec /i $InstallFile $MSISwitches -PassThru -Wait
    if ($StartInstall.ExitCode -eq "0") {

        Write-Host "Installation of $InstallFile completed successfully"
        exit 0

    } elseif ($StartInstall.ExitCode -ge "1") {

        Write-Host "Installation of $InstallFile failed"
        exit 1001

    }
    
    
} # If the Downloaded file is MSI

if ($InstallFileExt -eq ".msp") {

    $StartInstall = Start-Process msiexec /update $InstallFile $MSPSwitches -PassThru -Wait
    if ($StartInstall.ExitCode -eq "0") {

        Write-Host "Installation completed successfully"
        exit 0

    } elseif ($StartInstall.ExitCode -ge "1") {

        Write-Host "Installation of $InstallFile failed"
        exit 1001

    }
    
    
} # If the Downloaded file is MSP

} # End Try

Catch {
Write-Host "Installation Failed"
exit 1001
} # End Catch
