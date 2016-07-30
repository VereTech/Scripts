<# 
  .SYNOPSIS 
  This changes the system properties to include information about the service provider
  .DESCRIPTION 
  This script can be launched with no parameters, however you can customise it by
  passing parameters to it, see the PARAMETERS section for details
  #>
#
# Parameters
#
param (

[String]$OEMManufacturer = "VereTech",                                             # Support providers name
[String]$OEMSupportHours = "9AM to 5PM, Weekdays or check your SLA",                                             # Support available during these hours
[String]$OEMSupportPhone = "(03) 5153 2434",                                             # Support Phone Number
[String]$OEMSupportURL = "https://www.vere-tech.net.au/",                                               # Website for support
[String]$OEMLine1 = "Contact our Help Desk for computer problems",                                                     # Note to display to end users
[String]$LogoURL = "https://www.vere-tech.net.au/images/sysprop.bmp"                                                      # The URL to .bmp or .jpg Logo
)

$logfile = "$env:SystemDrive\VereTech\Log.txt"
$date = date
Write-Output "--------------------------------------------------------------------------------------------------" | Out-File -Append $logfile
Write-Output "$date : Starting 'branding system properties.ps1'" | Out-File -Append $logfile

Try {

#
# Variables
#

$Logooutput = "$env:SystemDrive\Windows\System32\oobe\sysprop.bmp" #for example C:\Users\User1\Desktop\logo1.jpg
$OEMInformation = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"

#
# Execution
#

# Download and format logo and store it
Write-Output "$date : Loading System.Drawing" | Out-File -Append $logfile
[reflection.assembly]::LoadWithPartialName("System.Drawing") | Out-Null


    if (!(Test-Path "$Logooutput")) {
        
        Write-Output "$date : Downloading $LogoURL to $Logooutput" | Out-File -Append $logfile
        Start-BitsTransfer -Source "$LogoURL" -Destination "$Logooutput"

    }
    Write-Output "$date : Re-Drawing $Logooutput" | Out-File -Append $logfile
    $Item = new-object System.Drawing.Bitmap $Logooutput
    $NewBitmap = new-object System.Drawing.Bitmap 110,110
    $g=[System.Drawing.Graphics]::FromImage($NewBitmap)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($Item, 0, 0, 110,110)
    $name="$env:SystemDrive\Windows\System32\oobe\logo.bmp"
    $NewBitmap.Save($name,([system.drawing.imaging.imageformat]::bmp)) 



# Brand the System Panel
# Change the Registry Keys

if (!(Test-Path "$OEMInformation")) {

    Write-Output "$date : Creating $OEMInformation" | Out-File -Append $logfile
    New-Item -Path $OEMInformation

}
Write-Output "$date : Creating OEM Registry Values under $OEMInformation" | Out-File -Append $logfile
Set-ItemProperty "$OEMInformation" -name "Manufacturer" -value "$OEMManufacturer"
Set-ItemProperty "$OEMInformation" -name "SupportHours" -value "$OEMSupportHours"
Set-ItemProperty "$OEMInformation" -name "SupportPhone" -value "$OEMSupportPhone"
Set-ItemProperty "$OEMInformation" -name "SupportURL" -value "$OEMSupportURL"
Set-ItemProperty "$OEMInformation" -name "Line1" -value "$OEMLine1"
Set-ItemProperty "$OEMInformation" -name "Logo" -value "$name"

$Query1 = Get-ItemPropertyValue "$OEMInformation" -name "Manufacturer"
$Query2 = Get-ItemPropertyValue "$OEMInformation" -name "SupportHours"
$Query3 = Get-ItemPropertyValue "$OEMInformation" -name "SupportPhone"
$Query4 = Get-ItemPropertyValue "$OEMInformation" -name "SupportURL"
$Query5 = Get-ItemPropertyValue "$OEMInformation" -name "Line1"
$Query6 = Get-ItemPropertyValue "$OEMInformation" -name "Logo"

$ChecksPassed = 0
if ($Query1 -eq $OEMManufacturer) {

    Write-Output "$date : Successfully set '$OEMManufacturer' as Manaufacturer" | Out-File -Append $logfile
    $ChecksPassed++

    } else {
    Write-Output "$date : Failed to set '$OEMManufacturer' as Manaufacturer" | Out-File -Append $logfile
    Write-Host "Failed to set '$OEMManufacturer' as Manufacturer"

}

if ($Query2 -eq $OEMSupportHours) {

    Write-Output "$date : Successfully set '$OEMSupportHours' as SupportHours" | Out-File -Append $logfile
    $ChecksPassed++

    } else {

    Write-Output "$date : Failed to set '$OEMSupportHours' as SupportHours" | Out-File -Append $logfile
    Write-Host "Failed to set '$OEMSupportHours' as SupportHours"

}

if ($Query3 -eq $OEMSupportPhone) {

    Write-Output "$date : Successfully set '$OEMSupportPhone' as SupportPhone" | Out-File -Append $logfile
    $ChecksPassed++

    } else {

    Write-Output "$date : Failed to set '$OEMSupportPhone' as SupportPhone" | Out-File -Append $logfile
    Write-Host "Failed to set '$OEMSupportPhone' as SupportPhone"

}

if ($Query4 -eq $OEMSupportURL) {

    Write-Output "$date : Successfully set '$OEMSupportURL' as SupportURL" | Out-File -Append $logfile
    $ChecksPassed++

    } else {

    Write-Output "$date : Failed to set '$OEMSupportURL' as SupportURL" | Out-File -Append $logfile
    Write-Host "Failed to set '$OEMSupportURL' as SupportURL"

}

if ($Query5 -eq $OEMLine1) {

    Write-Output "$date : Successfully set '$OEMLine1' as Line1" | Out-File -Append $logfile
    $ChecksPassed++

    } else {

    Write-Output "$date : Failed to set '$OEMLine1' as Line1" | Out-File -Append $logfile
    Write-Host "Failed to set '$OEMLine1' as Line1"

}

if ($Query6 -eq $name) {

    Write-Output "$date : Successfully set '$name' as Logo" | Out-File -Append $logfile
    $ChecksPassed++

    } else {

    Write-Output "$date : Failed to set '$name' as Logo" | Out-File -Append $logfile
    Write-Host "Failed to set '$name' as Logo"

}

if ($ChecksPassed -eq 6) {

    Write-Output "$date : This system has been branded as '$OEMManufacturer'" | Out-File -Append $logfile
    Write-Output "$date : Registry entries look like this:" | Out-File -Append $logfile
    Write-Output "$date : Manufacturer  = $Query1" | Out-File -Append $logfile
    Write-Output "$date : Support Hours = $Query2" | Out-File -Append $logfile
    Write-Output "$date : Support Phone = $Query3" | Out-File -Append $logfile
    Write-Output "$date : Support WWW   = $Query4" | Out-File -Append $logfile
    Write-Output "$date : End User Note = $Query5" | Out-File -Append $logfile
    Write-Output "$date : Logo File     = $Query6" | Out-File -Append $logfile

    Write-Host "This system has been branded as '$OEMManufacturer'"
    exit 0

} else {

    Write-Output "$date : $ChecksPassed out of 6 branding options where applied" | Out-File -Append $logfile
    Write-Output "$date : Registry entries look like this:" | Out-File -Append $logfile
    Write-Output "$date : Manufacturer  = $Query1" | Out-File -Append $logfile
    Write-Output "$date : Support Hours = $Query2" | Out-File -Append $logfile
    Write-Output "$date : Support Phone = $Query3" | Out-File -Append $logfile
    Write-Output "$date : Support WWW   = $Query4" | Out-File -Append $logfile
    Write-Output "$date : End User Note = $Query5" | Out-File -Append $logfile
    Write-Output "$date : Logo File     = $Query6" | Out-File -Append $logfile

    Write-Host "$ChecksPassed out of 6 branding options where applied"
    
    exit 1001

}
}


Catch {
    
    Write-Output "$date : Something went wrong..." | Out-File -Append $logfile
    Write-Host "Something went wrong..."
    exit 1001


} # End Catch
