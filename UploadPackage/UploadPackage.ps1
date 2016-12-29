$distdir = Get-VstsInput -Name "distdir" -Require
$repository = Get-VstsInput -Name "repository" -Require
$username = Get-VstsInput -Name "username" -Require
$password = Get-VstsInput -Name "password" -Require
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"
$skipexisting = Get-VstsInput -Name "skipexisting" -AsBool -Require
$otherargs = Get-VstsInput -Name "otherargs"

$py = gci $python -Recurse | select -Last 1

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

try {
    $env:TWINE_USERNAME = $username
    $env:TWINE_PASSWORD = $password
    Invoke-VstsTool $py "-m twine upload `"$distdir`" -r $repository $skip$otherargs" -RequireExitCodeZero
} finally {
    $env:TWINE_USERNAME = $null
    $env:TWINE_PASSWORD = $null
}
