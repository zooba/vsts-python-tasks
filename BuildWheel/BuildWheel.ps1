$setuppy = Get-VstsInput -Name "setuppy" -Default "setup.py"
$outputdir = Get-VstsInput -Name "outputdir" -Default "$($env:BUILD_BINARIESDIRECTORY)\dist"
$signcmd = Get-VstsInput -Name "signcmd" -Default ""
$universal = Get-VstsInput -Name "universal" -Require -AsBool
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"
$workingdir = Get-VstsInput -Name "workingdir" -Default "${env:BUILD_BINARIESDIRECTORY}"

$pythons = gci $python -Recurse

if ($universal) {
    $pythons = @($pythons | select -Last 1)
    $universalcmd = "--universal"
} else {
    $universalcmd = ""
}

if ($dependencies) {
    foreach ($py in $pythons) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }
}

foreach ($py in $pythons) {
    $arguments = "`"$setuppy`" build --build-base `"$workingdir`" $signcmd bdist_wheel -d `"$outputdir`" $universalcmd"
    Invoke-VstsTool $py $arguments (Resolve-Path $setuppy | Split-Path) -RequireExitCodeZero
}
