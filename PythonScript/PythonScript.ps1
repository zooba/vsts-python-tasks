$arguments = Get-VstsInput -Name "arguments" -Require
$workingdir = Get-VstsInput -Name "workingdir" -Default $env:SYSTEM_DEFAULTWORKINGDIRECTORY
$pythonroot = Get-VstsInput -Name "pythonroot" -Default $env:BUILD_BINARIESDIRECTORY
$pythonpattern = Get-VstsInput -Name "pythonpattern" -Require
$onlyone = Get-VstsInput -Name "onlyone" -AsBool
$dependencies = Get-VstsInput -Name "dependencies"

$pythons = Find-VstsMatch $pythonroot $pythonpattern
if ($onlyone) {
    $pythons = $pythons | select -last 1
}

foreach ($py in $pythons) {
    if ($dependencies) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }

    Invoke-VstsTool $py $arguments $workingdir
}
