$notebook = Get-VstsInput -Name "notebook" -Require
$outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
$jupyter = Get-VstsInput -Name "jupyter" -Default "${env:BUILD_BINARIESDIRECTORY}\env\Scripts\jupyter.exe"

$notebooks = Find-VstsMatch $env:SYSTEM_DEFAULTWORKINGDIRECTORY $notebook
$nbargs = "nbconvert --to html --execute --allow-errors --output-dir=`"$outputdir`""

foreach ($nb in $notebooks) {
    Invoke-VstsTool $jupyter "$nbargs `"$nb`"" -RequireExitCodeZero
}
