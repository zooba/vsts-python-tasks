Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $setuppy = Get-VstsInput -Name "setuppy" -Default "setup.py"
    $outputdir = Get-VstsInput -Name "outputdir" -Default "$($env:BUILD_BINARIESDIRECTORY)\dist"
    $dependencies = Get-VstsInput -Name "dependencies"
    $python = Get-PythonExe -Name "python"
    $workingdir = Get-VstsInput -Name "workingdir"

    if (-not $workingdir) {
        $workingdir = (Resolve-Path $setuppy | Split-Path)
    }

    if ($dependencies) {
        Invoke-VstsTool $python "-m pip install $dependencies" $workingdir
    }

    $arguments = '"{0}" sdist -d "{1}"' -f $setuppy, $outputdir
    Invoke-VstsTool $python $arguments $workingdir -RequireExitCodeZero

    Set-VstsTaskVariable -Name dist -Value $outputdir
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
