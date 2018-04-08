Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $notebook = Get-VstsInput -Name "notebook" -Require
    $outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
    $jupyter = Get-VstsInput -Name "jupyter" -Default "${env:BUILD_BINARIESDIRECTORY}\env\Scripts\jupyter.exe"

    $notebooks = Find-VstsMatch $env:SYSTEM_DEFAULTWORKINGDIRECTORY $notebook
    $nbargs = 'nbconvert --to html --execute --allow-errors --output-dir="{0}"' -f $outputdir

    foreach ($nb in $notebooks) {
        $arguments = '{0} "{1}"' -f $nbargs, $nb
        Invoke-VstsTool $jupyter $arguments -RequireExitCodeZero
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
