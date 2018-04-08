Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $arguments = Get-VstsInput -Name "arguments" -Require
    $workingdir = Get-VstsInput -Name "workingdir" -Default $env:SYSTEM_DEFAULTWORKINGDIRECTORY
    $onlyone = Get-VstsInput -Name "onlyone" -AsBool
    $abortOnFail = Get-VstsInput -Name "abortOnFail" -AsBool
    $dependencies = Get-VstsInput -Name "dependencies"

    if ($onlyone) {
        $python = Get-PythonExe -Name "python"
    } else {
        $python = Get-PythonExe -All -Name "python"
    }

    foreach ($py in $pythons) {
        if ($dependencies) {
            Invoke-VstsTool $py "-m pip install $dependencies" $workingdir
        }

        if ($abortOnFail) {
            Invoke-VstsTool $py $arguments $workingdir -RequireExitCodeZero
        } else {
            Invoke-VstsTool $py $arguments $workingdir
        }
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
