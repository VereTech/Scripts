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
function Unzip {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    param([string]$ZipFile, [string]$XFolder)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $XFolder)
}