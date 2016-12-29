$setuppy = Get-VstsInput -Name "setuppy" -Default "setup.py"
$outputdir = Get-VstsInput -Name "outputdir" -Default "$($env:BUILD_BINARIESDIRECTORY)\dist"
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"

if (Test-Path $python) {
    $py = $python
} else {
    $py = (gci $python -File -Recurse | select -Last 1)
}

if ($dependencies) {
    Invoke-VstsTool $py "-m pip install $dependencies"
}
$arguments = "`"$setuppy`" sdist -d `"$outputdir`""
Invoke-VstsTool $py $arguments (Resolve-Path $setuppy | Split-Path) -RequireExitCodeZero
