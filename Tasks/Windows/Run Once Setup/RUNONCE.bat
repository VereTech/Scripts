@echo off
cls

REM Setup Script
	set COMPANYFOLDER=%SYSTEMDRIVE%\VereTech
	set log=%COMPANYFOLDER%\RunOnce.log
	date /t >>%LOG%
	time /t >>%LOG%
REM Setup folders
	if not exist %COMPANYFOLDER%\Tools (md %COMPANYFOLDER%\Tools)
	if not exist %COMPANYFOLDER%\Packages (md %COMPANYFOLDER%\Packages)
	if not exist %COMPANYFOLDER%\Scripts (md %COMPANYFOLDER%\Scripts)

REM Create Download Script
	set DLOAD_SCRIPT=%TEMP%\download.vbs 
	echo Option Explicit >  %DLOAD_SCRIPT% 
	echo Dim args, http, fileSystem, adoStream, url, target, status >> %DLOAD_SCRIPT% 
	echo. >> %DLOAD_SCRIPT% 
	echo Set args = Wscript.Arguments >> %DLOAD_SCRIPT% 
	echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1") >> %DLOAD_SCRIPT% 
	echo url = args(0) >> %DLOAD_SCRIPT% 
	echo target = args(1) >> %DLOAD_SCRIPT% 
	echo WScript.Echo "Getting '" ^& target ^& "' from '" ^& url ^& "'..." >> %DLOAD_SCRIPT% 
	echo. >> %DLOAD_SCRIPT% 
	echo http.Open "GET", url, False >> %DLOAD_SCRIPT% 
	echo http.Send >> %DLOAD_SCRIPT% 
	echo status = http.Status >> %DLOAD_SCRIPT% 
	echo. >> %DLOAD_SCRIPT% 
	echo If status ^<^> 200 Then >> %DLOAD_SCRIPT% 
	echo WScript.Echo "FAILED to download: HTTP Status " ^& status >> %DLOAD_SCRIPT% 
	echo WScript.Quit 1 >> %DLOAD_SCRIPT% 
	echo End If >> %DLOAD_SCRIPT% 
	echo. >> %DLOAD_SCRIPT% 
	echo Set adoStream = CreateObject("ADODB.Stream") >> %DLOAD_SCRIPT% 
	echo adoStream.Open >> %DLOAD_SCRIPT% 
	echo adoStream.Type = 1 >> %DLOAD_SCRIPT% 
	echo adoStream.Write http.ResponseBody >> %DLOAD_SCRIPT% 
	echo adoStream.Position = 0 >> %DLOAD_SCRIPT% 
	echo. >> %DLOAD_SCRIPT% 
	echo Set fileSystem = CreateObject("Scripting.FileSystemObject") >> %DLOAD_SCRIPT% 
	echo If fileSystem.FileExists(target) Then fileSystem.DeleteFile target >> %DLOAD_SCRIPT% 
	echo adoStream.SaveToFile target >> %DLOAD_SCRIPT% 
	echo adoStream.Close >> %DLOAD_SCRIPT% 
	echo. >> %DLOAD_SCRIPT% 

REM For XP SP3 ONLY
REM If PowerShell 2 is not installed, download and install it.
	REM detect if XP SP3
		echo "checking if xp sp3" >>%LOG%
		ver | find "XP" > nul
		if %ERRORLEVEL% neq 0 goto :not_xp

		ver | find "5.1.2600" > nul
		if %ERRORLEVEL% neq 0 goto :not_xp_sp3

		echo "yep, xp sp3" >>%LOG%
	REM check if powershell already exists check which version
		:checkpowershell
		echo "checking if powershell is installed" >>%LOG%
		if not exist "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" goto :checknet
		echo "powershell is here, checking what version it is" >>%LOG%
		"%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -command "exit $PSVersionTable.PSVersion.Major"
		set PSVer=%errorlevel%
		echo "its version %PSVer%" >>%LOG%
		
	REM check if powershell is already v2 
		echo "checking if its version 2" >>%LOG%
		if %PSVer% geq 2 goto :already_installed

	REM check if .NET 2.0 SP1 is installed
		:checknet
		echo "checking if .net is installed" >>%LOG%
		if exist "%SYSTEMROOT%\Microsoft.NET\Framework\v2.0.50727" (goto :download)
		echo "nope, .net isnt here..." >>%LOG%
		
	REM Download .NET
		:downloadnet
		echo "checking if i already downloaded .net previously, if i havnt i will start downloading it" >>%LOG%
		if not exist %COMPANYFOLDER%\Packages\NetFx20SP1_x86.exe (cscript //Nologo %DLOAD_SCRIPT% https://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe %COMPANYFOLDER%\Packages\NetFx20SP1_x86.exe) 
		
		echo "checking if .net installer is downloaded again, this runs weather i tried to download it or not since last time" >>%LOG%
		if not exist %COMPANYFOLDER%\Packages\NetFx20SP1_x86.exe goto :DownloadnetFailed
		echo "yep, .net installer is there" >>%LOG%
	REM Install .NET
		:installnet
		echo "Installing .NET..." >>%LOG%
		cd %COMPANYFOLDER%\Packages
		start /wait cmd /c "NetFx20SP1_x86.exe /quiet /norestart"
		echo "i finished trying to install .net, going to check if it is installed" >>%LOG%
		if not exist "%SYSTEMROOT%\Microsoft.NET\Framework\v2.0.50727" goto :installnetfailed
		echo ".NET 2.0 SP1 is now installed" >>%LOG%
		
		
	REM Download powershell 2
		:download
		echo "if i havnt previously downloaded powershell 2 installer, im going to" >>%LOG%
		if not exist %COMPANYFOLDER%\Packages\WindowsXP-KB968930-x86-ENG.exe (cscript //Nologo %DLOAD_SCRIPT% http://download.microsoft.com/download/E/C/E/ECE99583-2003-455D-B681-68DB610B44A4/WindowsXP-KB968930-x86-ENG.exe %COMPANYFOLDER%\Packages\WindowsXP-KB968930-x86-ENG.exe) else (goto :installps2)
		echo "checking if powershell 2 installer is downloaded again, this runs weather i tried to download it or not since last time" >>%LOG%
		if not exist %COMPANYFOLDER%\Packages\WindowsXP-KB968930-x86-ENG.exe goto :DownloadFailed
		echo "yep, powershell 2 installer is there"
	REM Install Powershell 2
		:installps2
		echo "Installing PowerShell 2..." >>%LOG%
		cd %COMPANYFOLDER%\Packages
		start /wait cmd /c "WindowsXP-KB968930-x86-ENG.exe /quiet /norestart"
		echo "i finished tring to install powershell 2, going to see if its there" >>%LOG%
		if not exist "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" goto :install_failed
		echo "PowerShell 2 is now installed" >>%LOG%
		goto :endxp

	REM Some exit failures
		:DownloadFailed
		echo "Failed to Download PowerShell 2" >>%LOG%
		exit 1001

		:install_failed
		echo "PowerShell 2 installation failed." >>%LOG%
		exit 1001
		
		:DownloadnetFailed
		echo "Failed to Download .NET 2.0 SP1" >>%LOG%
		exit 1001
		
		:installnetfailed
		echo ".NET 2.0 SP1 installation failed" >>%LOG%
		exit 1001

		:not_xp_sp3
		echo "Failed: Install Service Pack 3 for XP and try again." >>%LOG%
		exit 1001

		:already_installed
		echo "PowerShell 2 or higher is already installed." >>%LOG%
		goto :endxp


REM Anything else for XP SP3 goes here
:endxp

REM Add code here for non XP SP3 specific
:not_xp

REM Set the execution policy for powershell to RemoteSigned from any value
	echo "going to set powershells execution policy to remote signed now, and no, im not going to check if it worked, hummph :(" >>%LOG%
	REG ADD "HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /d RemoteSigned /t REG_SZ /f

	
REM Cleanup and Exit success
echo "starting the cleanup now, which is unlike me, usually i leave my junk around everywhere" >>%LOG%
del /q /f %DLOAD_SCRIPT%
echo "Success"	
exit 0