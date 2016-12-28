$setuppy = Get-VstsInput -Name "setuppy" -Default "setup.py"
$outputdir = Get-VstsInput -Name "outputdir" -Default "$($env:BUILD_BINARIESDIRECTORY)\dist"
$signcmd = Get-VstsInput -Name "signcmd" -Default ""
$universal = Get-VstsInput -Name "universal" -Require -AsBool
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"
$workingdir = Get-VstsInput -Name "workingdir" -Default "${env:BUILD_BINARIESDIRECTORY}"

if (Test-Path $python) {
    $pythons = @($python)
} else {
    $pythons = gci $python -File -Recurse
}

if ($universal) {
    $pythons = @($pythons | select -Last 1)
    $universalcmd = "--universal"
} else {
    $universalcmd = ""
}

foreach ($py in $pythons) {
    if ($dependencies) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }
    $arguments = "`"$setuppy`" build --build-base `"$workingdir`" $signcmd bdist_wheel -d `"$outputdir`" $universalcmd"
    Invoke-VstsTool $py $arguments (Resolve-Path $setuppy | Split-Path) -RequireExitCodeZero
}
