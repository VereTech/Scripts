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



[reflection.assembly]::LoadWithPartialName("System.Drawing") | Out-Null

    if (!(Test-Path "$Logooutput")) {

        Start-BitsTransfer -Source "$LogoURL" -Destination "$Logooutput"

    }

    $Item = new-object System.Drawing.Bitmap $Logooutput
    $NewBitmap = new-object System.Drawing.Bitmap 110,110
    $g=[System.Drawing.Graphics]::FromImage($NewBitmap)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($Item, 0, 0, 110,110)
    $name="$env:SystemDrive\Windows\System32\oobe\logo.bmp"
    $NewBitmap.Save($name,([system.drawing.imaging.imageformat]::bmp)) 



# Brand the System Panel
# Change the Registry Keys
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

    $ChecksPassed++

    } else {

    Write-Host "Failed to set $OEMManufacturer as Manufacturer"

}

if ($Query2 -eq $OEMSupportHours) {

    $ChecksPassed++

    } else {

    Write-Host "Failed to set $OEMSupportHours as SupportHours"

}

if ($Query3 -eq $OEMSupportPhone) {

    $ChecksPassed++

    } else {

    Write-Host "Failed to set $OEMSupportPhone as SupportPhone"

}

if ($Query4 -eq $OEMSupportURL) {

    $ChecksPassed++

    } else {

    Write-Host "Failed to set $OEMSupportURL as SupportURL"

}

if ($Query5 -eq $OEMLine) {

    $ChecksPassed++

    } else {

    Write-Host "Failed to set $OEMLine as Line1"

}

if ($Query6 -eq $name) {

    $ChecksPassed++

    } else {

    Write-Host "Failed to set $name as Logo"

}

if ($ChecksPassed -eq 6) {

    Write-Host "This system has been branded as $OEMManufacturer"
    Write-Host "Manufacturer  = $Query1"
    Write-Host "Support Hours = $Query2"
    Write-Host "Support Phone = $Query3"
    Write-Host "Support WWW   = $Query4"
    Write-Host "End User Note = $Query5"
    Write-Host "Logo File     = $Query6"
    exit 0

} else {

    Write-Host "$ChecksPassed out of 6 branding options where applied"
    Write-Host "Manufacturer  = $Query1"
    Write-Host "Support Hours = $Query2"
    Write-Host "Support Phone = $Query3"
    Write-Host "Support WWW   = $Query4"
    Write-Host "End User Note = $Query5"
    Write-Host "Logo File     = $Query6"
    exit 1001

}
}


Catch {

    Write-Host "Something went wrong..."
    exit 1001


} # End Catch
