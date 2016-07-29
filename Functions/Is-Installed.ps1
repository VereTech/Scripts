<# 
  .SYNOPSIS 
  Search for installed Applications where the application name is "like" the passed parameter.
  This uses the registry to conduct its search instead of WMIC. 
  .DESCRIPTION 
  Set registry search folders based on systems Archetecture (64 or 32 bit)
  .EXAMPLE 
  Is-Installed "7-Zip"
  .EXAMPLE 
  Is-Installed "Acrobat"
  .PARAMETER IsApp
  The application name to search for. 
  #>

function Is-Installed( $IsApp ) {
    
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$IsApp*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$IsApp*" } ).Length -gt 0;

    return $x86 -or $x64;
}
