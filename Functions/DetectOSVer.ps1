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