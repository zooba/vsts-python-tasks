Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $setuppy = Get-VstsInput -Name "setuppy" -Default "setup.py"
    $builddir = Get-VstsInput -Name "builddir" -Default "$($env:BUILD_BINARIESDIRECTORY)"
    $outputdir = Get-VstsInput -Name "outputdir" -Default "$($env:BUILD_BINARIESDIRECTORY)\dist"
    $signcmd = Get-VstsInput -Name "signcmd" -Default ""
    $universal = Get-VstsInput -Name "universal" -Require -AsBool
    $dependencies = Get-VstsInput -Name "dependencies"
    $workingdir = Get-VstsInput -Name "workingdir"
    $usemsbuild = Get-VstsInput -Name "usemsbuild" -Require -AsBool

    if ($universal) {
        $python = Get-PythonExe -Name "python"
        $universalcmd = "--universal"
    } else {
        $python = Get-PythonExe -All -Name "python"
        $universalcmd = ""
    }

    if ($usemsbuild) {
        $usemsbuildcmd = "enable_msbuildcompiler"
    } else {
        $usemsbuildcmd = ""
    }

    if (-not $workingdir) {
        $workingdir = (Resolve-Path $setuppy | Split-Path)
    }

    foreach ($py in $python) {
        if ($dependencies) {
            Invoke-VstsTool $py "-m pip install $dependencies" $workingdir
        }
        if ($usemsbuild -and -not ($dependencies -match '\bpyfindvs\b')) {
            Invoke-VstsTool $py "-m pip install pyfindvs" $workingdir
        }

        $arguments = '"{0}" {1} build --build-base "{2}" {3} bdist_wheel -d "{4}" {5}' -f 
            $setuppy, $usemsbuildcmd, $builddir, $signcmd, $outputdir, $universalcmd

        Invoke-VstsTool $py $arguments $workingdir -RequireExitCodeZero
    }

    Set-VstsTaskVariable -Name dist -Value $outputdir
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
