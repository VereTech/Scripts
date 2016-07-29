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
[Parameter(Mandatory=$true)]
[string]$URL,
[string]$OutputFolder = "$env:SystemDrive\VereTech",
[string]$OutputFile
)  

if ($OutputFile -eq "") {
    $OutputFile = [System.IO.Path]::GetFileName($URL)
}          # If no Filename given, try and get it from given URL

if ($OutputFile -eq "") {
    Write-Error "DownloadURL: Cannot get Filename from $URL, please provide one using -OutputFile Filename.zip"
    return "FALSE"
}          # If cannot get filename from URL, Write-Error

If (!(Test-Path "$Outputfolder")) {

    Write-Error "DownloadURL: The Folder $OutputFolder does not exist"
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
    Write-Error "Download failed"
    return "FALSE"
}          # If file exists return the full file path, if file still doesnt exist, Write-Error



} # End Function