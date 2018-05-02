Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $setuppy = Get-VstsInput -Name "setuppy" -Default "setup.py"
    $builddir = Get-VstsInput -Name "builddir" -Require
    $outputdir = Get-VstsInput -Name "outputdir" -Require
    $signcmd = Get-VstsInput -Name "signcmd" -Default ""
    $universal = Get-VstsInput -Name "universal" -Require -AsBool
    $dependencies = Get-VstsInput -Name "dependencies"
    $workingdir = Get-VstsInput -Name "workingdir"
    $usemsbuild = Get-VstsInput -Name "usemsbuild" -Require -AsBool
    $python = Get-PythonExe -Name "pythonpath"

    if (-not $workingdir) {
        $workingdir = (Resolve-Path $setuppy | Split-Path)
    }

    if ($dependencies) {
        Invoke-VstsTool $python "-m pip install $dependencies" $workingdir
    }
    if ($usemsbuild -and -not ($dependencies -match '\bpyfindvs\b')) {
        Invoke-VstsTool $python "-m pip install pyfindvs" $workingdir
    }

    $arguments = '"{0}"' -f $setuppy
    if ($usemsbuild) {
        $arguments = "$arguments enable_msbuildcompiler"
    }
    $arguments = '{0} build --build-base "{1}"' -f ($arguments, $builddir)
    if ($signcmd) {
        $arguments = "$arguments $signcmd"
    }
    $arguments = '{0} bdist_wheel -d "{1}"' -f ($arguments, $outputdir)
    if ($universal) {
        $arguments = "$arguments --universal"
    }

    Invoke-VstsTool $python $arguments $workingdir -RequireExitCodeZero

    Set-VstsTaskVariable -Name dist -Value $outputdir
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
