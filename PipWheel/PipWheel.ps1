Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $packages = Get-VstsInput -Name "packages" -Default $env:BUILD_SOURCESDIRECTORY
    $outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
    $python = Get-PythonExe -Name "pythonpath"
    $dependencies = Get-VstsInput -Name "dependencies"
    $workingdir = Get-VstsInput -Name "workingdir" -Default $env:SYSTEM_DEFAULTWORKINGDIRECTORY

    if (-not ($packages -match '^".+"$') -and (Test-Path $packages)) {
        $packages = '"{0}"' -f $packages
    }

    if ($dependencies) {
        Invoke-VstsTool $python "-m pip install $dependencies" $workingdir
    }

    $arguments = '-m pip wheel -w "{0}" {1}' -f ($outputdir, $packages)
    Invoke-VstsTool $python $arguments $workingdir -RequireExitCodeZero

    Set-VstsTaskVariable -Name dist -Value $outputdir
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
