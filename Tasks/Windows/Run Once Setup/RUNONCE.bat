@echo off
cls

REM Setup, general configuration of script
	set COMPANYNAME=VereTech
	set SCRIPTNAME=RUNONCE.bat
	set COMPANYFOLDER=%SYSTEMDRIVE%\%COMPANYNAME%

REM Setup folders
	if not exist %COMPANYFOLDER% (md %COMPANYFOLDER%)
	if not exist %COMPANYFOLDER%\Tools (md %COMPANYFOLDER%\Tools)
	if not exist %COMPANYFOLDER%\Packages (md %COMPANYFOLDER%\Packages)
	if not exist %COMPANYFOLDER%\Scripts (md %COMPANYFOLDER%\Scripts)
	
	if not exist %COMPANYFOLDER% (
		echo attempt to create %COMPANYFOLDER% failed
		exit 1001
		) else (
			echo %COMPANYFOLDER% exists
			)
		
REM Setup Logging
	set LOG=%COMPANYFOLDER%\RUNONCE.txt
	echo --------------------------------------------------------------------------------------------------->>%LOG%
	echo Start of %SCRIPTNAME%>>%LOG%
	echo --------------------------------------------------------------------------------------------------->>%LOG%
	echo | date /t >>%LOG%
	echo | time /t >>%LOG%
	echo Company Name : %COMPANYNAME%>>%LOG%
	echo Company Folder : %COMPANYFOLDER%>>%LOG%
	echo.>>%LOG%
	


REM Create Download Script
	set DLOAD_SCRIPT=%COMPANYFOLDER%\Scripts\DownloadURL.vbs
	echo Self creating DownloadURL VB Script to %DLOAD_SCRIPT%>>%LOG%
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

if exist %DLOAD_SCRIPT% (
	echo Created DownloadURL VB Script successfully>>%LOG%
	) else (
		echo Failed creating DownloadURL VB Script>>%LOG%
		exit 1001
		)
echo.>>%LOG%

REM For XP SP3 ONLY
REM If PowerShell 2 is not installed, download and install it.
	REM detect if XP SP3
		echo Checking if this computer is Windows XP>>%LOG%
		ver | find "XP" > nul
		if %ERRORLEVEL% neq 0 goto :not_xp

		echo Checking if this computer is Windows XP SP3>>%LOG%
		ver | find "5.1.2600" > nul
		if %ERRORLEVEL% neq 0 goto :not_xp_sp3

		echo Yes, this computer is Windows XP SP3 >>%LOG%
	REM check if powershell already exists check which version
		:checkpowershell
		echo Checking if powershell is installed... >>%LOG%
		if not exist "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" goto :checknet
		echo Found Powershell, checking what version it is now... >>%LOG%
		"%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -command "exit $PSVersionTable.PSVersion.Major"
		set PSVer=%errorlevel%
		echo Powershell is version %PSVer% >>%LOG%
		
	REM check if powershell is already v2 
		if %PSVer% geq 2 (
			echo PowerShell 2 or higher is already installed. Skipping installation. >>%LOG%
			goto :endxp
			)

	REM check if .NET 2.0 SP1 is installed
		:checknet
		echo Checking if .NET 2.0 SP1 is installed... >>%LOG%
		if exist "%SYSTEMROOT%\Microsoft.NET\Framework\v2.0.50727" (
			echo .NET 2.0 SP1 already installed>>%LOG%
			goto :download
			) else (
				echo .NET 2.0 SP1 is not installed>>%LOG%
				goto :downloadnet
				)
		
	REM Download .NET
		:downloadnet
		echo Checking if i already downloaded .NET 2.0 SP1 previously>>%LOG%
		if not exist %COMPANYFOLDER%\Packages\NetFx20SP1_x86.exe (
			echo Can't find previously downloaded .NET 2.0 SP1 installer >>%LOG%
			echo Downloading .NET 2.0 SP1>>%LOG%
			cscript //Nologo %DLOAD_SCRIPT% https://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe %COMPANYFOLDER%\Packages\NetFx20SP1_x86.exe
			if not exist %COMPANYFOLDER%\Packages\NetFx20SP1_x86.exe (
				echo Failed to download .NET 2.0 SP1 from https://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe>>%LOG%
				exit 1001
				) else (
					echo Looks like the .NET 2.0 SP1 installer file does already exist>>%LOG%
					)
				)
	REM Install .NET
		:installnet
		echo Installing .NET... >>%LOG%
		cd %COMPANYFOLDER%\Packages
		start /wait cmd /c "NetFx20SP1_x86.exe /quiet /norestart"
		echo Finished trying to install .net, checking if I can access it..." >>%LOG%
		if not exist "%SYSTEMROOT%\Microsoft.NET\Framework\v2.0.50727" (
			echo .NET 2.0 SP1 installation failed>>%LOG%
			exit 1001
			) else (
				echo .NET 2.0 SP1 is now installed >>%LOG%
				)

	REM Download powershell 2
		:download
		echo Checking if I already downloaded Powershell 2 installer previously >>%LOG%
		if not exist %COMPANYFOLDER%\Packages\WindowsXP-KB968930-x86-ENG.exe (
			echo Can't find previously downloaded Powershell 2 installer >>%LOG%
			echo Downloading Powershell 2 installer
			cscript //Nologo %DLOAD_SCRIPT% http://download.microsoft.com/download/E/C/E/ECE99583-2003-455D-B681-68DB610B44A4/WindowsXP-KB968930-x86-ENG.exe %COMPANYFOLDER%\Packages\WindowsXP-KB968930-x86-ENG.exe
			if not exist %COMPANYFOLDER%\Packages\WindowsXP-KB968930-x86-ENG.exe (
				echo Failed to download Powershell 2 installer from http://download.microsoft.com/download/E/C/E/ECE99583-2003-455D-B681-68DB610B44A4/WindowsXP-KB968930-x86-ENG.exe>>%LOG%
				exit 1001
				) else (
					echo Looks like the Powershell 2 installer file does already exist>>%LOG%
					)
				)

	REM Install Powershell 2
		echo Installing PowerShell 2... >>%LOG%
		cd %COMPANYFOLDER%\Packages
		start /wait cmd /c "WindowsXP-KB968930-x86-ENG.exe /quiet /norestart"
		if not exist %SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe (
			echo PowerShell 2 installation failed. >>%LOG%
			exit 1001
			) else (
				echo PowerShell 2 is now installed >>%LOG%
				goto :endxp
				)

	REM Some exit failures
		:not_xp_sp3
		echo Failed: Install Service Pack 3 for XP and try again. >>%LOG%
		exit 1001

REM Anything else for XP SP3 goes here
:endxp


REM Add code here for non XP SP3 specific
:not_xp


	
REM Set the execution policy for powershell to RemoteSigned from any value
echo Setting Powershells ExecutionPolicy to RemoteSigned>>%LOG%
REG ADD "HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v ExecutionPolicy /d RemoteSigned /t REG_SZ /f
if %ERRORLEVEL% == 0 (
	echo Successfully set Powershells ExecutionPolicy to RemoteSigned>>%LOG%
	)
	
	
REM Ensure windows passwords are not storing reversable hash's
echo.>>%LOG%
echo Ensuring PC is protected against NoLMHash vulverability>>%LOG%
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /v NoLMHash /t REG_DWORD /d 0x1 /f
if %ERRORLEVEL% == 0 (
	echo Either PC was already protected or it is now protected>>%LOG%
	) else (
	echo Failed to set NoLMHash>>%LOG%
	exit 1001
	)
echo End of NoLMHash check>>%LOG%


REM Cleanup and Exit
	echo Starting the cleanup now >>%LOG%
	del /q /f %DLOAD_SCRIPT%
	echo END OF SCRIPT>>%LOG%
	echo "Success"	
	exit 0