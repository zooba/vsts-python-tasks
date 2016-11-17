param(
    [string]$packages,
    [string]$outputdir,
    [string]$python,
    [string]$dependencies
)

if (-not $outputdir) {
    $outputdir = $env:BUILD_BINARIESDIRECTORY
}

if (Test-Path $python) {
    $pythons = @($python)
} else {
    $pythons = gci $python -File -Recurse
}

foreach($py in (gci $python -File -Recurse)) {
    if ($dependencies) {
        Invoke-Tool -Path $py -Arguments "-m pip install $dependencies"
    }
    Invoke-Tool -Path $py -Arguments "-m pip wheel -w `"$outputdir`" $packages"
}
