$distdir = Get-VstsInput -Name "distdir" -Require
$repository = Get-VstsInput -Name "repository" -Require
$username = Get-VstsInput -Name "username" -Require
$password = Get-VstsInput -Name "password" -Require
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"
$skipexisting = Get-VstsInput -Name "skipexisting" -AsBool -Require
$otherargs = Get-VstsInput -Name "otherargs"

if (Test-Path $python) {
    $py = $python
} else {
    $py = gci $python -File -Recurse | select -First 1
}

if ($dependencies) {
    Invoke-VstsTool $py "-m pip install $dependencies"
}

if ($skipexisting) {
    $skip = " --skip-existing"
} else {
    $skip = ""
}

if ($otherargs) {
    $otherargs = " $otherargs"
} else {
    $otherargs = ""
}

Invoke-VstsTool $py "-m twine upload `"$distdir`" -r $repository -u $username -p $password$skip$otherargs" -DisplayArguments "-m twine `"$distdir`" -r $repository -u ***** -p *****$skip$otherargs"
