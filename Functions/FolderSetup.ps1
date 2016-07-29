function FolderSetup {
<# 
  .SYNOPSIS 
  Setups folder Sctructure under C:\                 \    VereTech              \    Tools   
                                 $env:SystemDrive    \    $CompanyFolderName    \    $CompanySubFolders

  .DESCRIPTION 
  Sub folders can be entered with a "\" to create further sub folders, for example "Tools\Putty"
  .EXAMPLE 
  FolderSetup -CompanyFolderName "VereTech" -CompanySubFolders "Tools\Install","Tools\Download","Packages\Adobe"
  #>
#
# Parameters
#
param(
[string]$CompanyFolderName,
$CompanySubFolders
)

#
# SETUP
#
$CompanySubFolders += (

    "Tools",
    "Scripts",
    "Packages"
    
)


$CompanyFolderDrive = $env:SystemDrive

#
# Execute
#
if ($CompanyFolderName -eq "") {

    Write-Warning "Please pass the Root folder name using parameter -CompanyFolderName"
    return "FALSE"

}

foreach ($CompanySubFolder in $CompanySubFolders) {
    if (!(Test-Path "$CompanyFolderDrive\$CompanyFolderName\$CompanySubFolder")) {
        New-Item -Path "$CompanyFolderDrive\$CompanyFolderName\$CompanySubFolder" -ItemType Directory|Out-Null
    }
}
$FolderCount = 0
foreach ($CompanySubFolder in $CompanySubFolders) {
    $FolderCount++
}


$FolderCountSuccess = 0
foreach ($CompanySubFolder in $CompanySubFolders) {
    if (Test-Path "$CompanyFolderDrive\$CompanyFolderName\$CompanySubFolder") {
        $FolderCountSuccess++
    }
}
if ("$FolderCountSuccess" -eq "$FolderCount") {

    return "TRUE"

} else {
    
    return "FALSE"

}

} # End Function