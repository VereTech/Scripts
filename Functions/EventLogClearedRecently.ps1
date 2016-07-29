﻿<# 
  .SYNOPSIS 
  Checks to see if the System, Security or Application EventLogs have been cleared within the last week.
  .DESCRIPTION
  Returns a exitcode of 0 if all logs havent been cleared within the lastweek
  Returns a exitcode of 1001 if any logs have been cleared within the last week, also displays a a warning showing 
  the log name, the date and time it was cleared, the username who cleared it, and which computer on the network initiated the clear.
  .EXAMPLE
  EventLogClearedRecently
  #>

function EventLogClearedRecently {

$Date = Get-Date
$TimeFrame = $Date.AddDays(-7)

$ExitCode = "0"

$SecClearedTimeGenerated = ""
$SecCleared = Get-EventLog -LogName Security -EntryType SuccessAudit -After $TimeFrame -ComputerName $env:COMPUTERNAME -InstanceId 1102
$SecClearedTimeGenerated = $SecCleared.TimeGenerated
$SecUser = $SecCleared.UserName
$SecComputer = $SecCleared.MachineName

$SysClearedTimeGenerated = ""
$SysCleared = Get-EventLog -LogName System -EntryType Information -After $TimeFrame -ComputerName $env:COMPUTERNAME -InstanceId 104 -Message "The System log file was cleared."
$SysClearedTimeGenerated = $SysCleared.TimeGenerated
$SysUser = $SysCleared.UserName
$SysComputer = $SysCleared.MachineName

$AppClearedTimeGenerated = ""
$AppCleared = Get-EventLog -LogName System -EntryType Information -After $TimeFrame -ComputerName $env:COMPUTERNAME -InstanceId 104 -Message "The Application log file was cleared."
$AppClearedTimeGenerated = $AppCleared.TimeGenerated
$AppUser = $AppCleared.UserName
$AppComputer = $AppCleared.MachineName


if ($SecCleared.TimeGenerated -ge $TimeFrame) {

    Write-Warning "The Security EventLog was CLEARED at: $SecClearedTimeGenerated by '$SecUser' from '$SecComputer'"

    if ($ExitCode -eq 0) {
        
        $ExitCode = 1001

    }
    
}

if ($SysCleared.TimeGenerated -ge $TimeFrame) {

    Write-Warning "The System EventLog was CLEARED at: $SysClearedTimeGenerated by '$SysUser' from '$SysComputer'"

    if ($ExitCode -eq 0) {
        
        $ExitCode = 1001

    }
    
}

if ($AppCleared.TimeGenerated -ge $TimeFrame) {

    Write-Warning "The Application EventLog was CLEARED at: $AppClearedTimeGenerated by '$AppUser' from '$AppComputer'"

    if ($ExitCode -eq 0) {
        
        $ExitCode = 1001

    }
}
return $ExitCode

} # End Function