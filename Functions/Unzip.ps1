###########################################################################################################
# This function unzips a compressed ZIP archive using the systems compression enginethe passed parameters #
# Parameters :                                                                                            #
# -ZipFile "compressed.zip"                                                                               #
# -XFolder                                                                                                #
###########################################################################################################

function Unzip {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    param([string]$ZipFile, [string]$XFolder)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $XFolder)
}