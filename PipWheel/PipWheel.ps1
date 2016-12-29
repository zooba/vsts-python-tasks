$packages = Get-VstsInput -Name "packages" -Require
$outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"

if (Test-Path $python) {
    $pythons = @($python)
} else {
    $pythons = gci $python -File -Recurse
}

foreach($py in $pythons) {
    if ($dependencies) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }
    Invoke-VstsTool $py "-m pip wheel -w `"$outputdir`" $packages"
}
