
function _restart_service()
{
$comp = gc env:computername
$SrvName = "Spooler"
try {
stop-service -Name Spooler -Force
Start-Sleep 5
start-service -Name Spooler
Write-Host "Spooler Service Resarted"
Exit 0
}
 catch 
 {
 Write-Host "Something went wrong restarting Print Spooler service"
 Exit 1001
 }

}
function _chkservice()	
{
$comp = gc env:computername
Write-Host $comp
$chService = Get-Service -Name 'Spooler'
    if ($chService.Status -eq "Running"){
		Write-Host "The Print Spooler service is running"
		Exit 0
}	else 
		{
		_restart_service		
		}
}
function _remove_item_all($day)
{
$comp = gc env:computername
try {

stop-service -Name Spooler -Force
$date = Get-Date 
$oldday =$day
$old_file = $date.AddDays(-$oldday)
$Files = Get-ChildItem "\\$comp\C$\windows\system32\spool\printers" -Recurse | Where {$_.LastWriteTime -le "$old_file"}
foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        
        Remove-Item $File.FullName | out-null
		start-service -Name Spooler
		Write-Host "Success Message"		
		Exit 0
        }
    else
        {
        Write-Host "No files to delete"
		Exit 1001
        }
    }


 } catch 
 {
 Write-Host "Error Messages"
		Exit 1001
 }
}

 if ($args[0].length -eq 0)
   { 
   Write-Host "Error Message"
   Exit 1001
   } else {
     $comp=gc env:computername
   	switch -regex ($args[0]) 
    { 
        "restart" {_restart_service } 
        "remove" {if ($args[1].length -eq 0 )
						{
						Write-Host"Error Message"
						Exit 1001
						} else 
						{
						_remove_item_all($args[1])
						}
						}
        "chkservice" {_chkservice } 
        
        default {
		Write-Host "Error Message"
		Exit 1001}
    }


	
	
	}
	
	
