Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $script = Get-VstsInput -Name "script"
    $args = Get-VstsInput -Name "arguments"
    $workingdir = Get-VstsInput -Name "workingdir" -Default $env:SYSTEM_DEFAULTWORKINGDIRECTORY
    $abortOnFail = Get-VstsInput -Name "abortOnFail" -AsBool
    $dependencies = Get-VstsInput -Name "dependencies"
    $python = Get-PythonExe -Name "pythonpath"

    if (Test-Path $script -PathType Leaf) {
        $arguments = '"{0}" {1}' -f $script, $args
    } else {
        $arugments = $args
    }

    if ($dependencies) {
        Invoke-VstsTool $python "-m pip install $dependencies" $workingdir
    }

    if ($abortOnFail) {
        Invoke-VstsTool $python $arguments $workingdir -RequireExitCodeZero
    } else {
        Invoke-VstsTool $python $arguments $workingdir
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
