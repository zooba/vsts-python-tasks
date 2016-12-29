$packages = Get-VstsInput -Name "packages" -Require
$outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"

$pythons = gci $python -Recurse

if ($dependencies) {
    foreach($py in $pythons) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }
}

foreach($py in $pythons) {
    Invoke-VstsTool $py "-m pip wheel -w `"$outputdir`" $packages"
}
