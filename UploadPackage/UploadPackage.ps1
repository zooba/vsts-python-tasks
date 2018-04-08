Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $distdir = Get-VstsInput -Name "distdir"
    $repository = Get-VstsInput -Name "repository" -Require
    $pypirc = Get-VstsInput -Name "pypirc"
    $username = Get-VstsInput -Name "username"
    $password = Get-VstsInput -Name "password"
    $python = Get-PythonExe -Name "python"
    $dependencies = Get-VstsInput -Name "dependencies"
    $skipexisting = Get-VstsInput -Name "skipexisting" -AsBool -Require
    $otherargs = Get-VstsInput -Name "otherargs"

    if ($dependencies) {
        Invoke-VstsTool $python "-m pip install $dependencies"
    }

    $args = "-r $repository"
    if (Test-Path $pypirc -PathType Leaf) {
        $args = '{0} --config-file "{1}"' -f $args, $pypirc
    }
    if ($skipexisting) {
        $args = "$args --skip-existing"
    }
    if ($otherargs) {
        $args = "$args $otherargs"
    }

    try {
        $env:TWINE_USERNAME = $username
        $env:TWINE_PASSWORD = $password
        if ($distdir) {
            if (Test-Path $distdir -PathType Container) {
                $distdir = Join-Path $distdir '*'
            }
            $arguments = '-m twine upload "{0}" {1}' -f $distdir, $args
            Invoke-VstsTool $python $arguments -RequireExitCodeZero
        } else {
            $d1 = Get-VstsTaskVariable -Name "BuildSDist.dist"
            $d2 = Get-VstsTaskVariable -Name "BuildWheel.dist"
            $d3 = Get-VstsTaskVariable -Name "PipWheel.dist"
            ($d1, $d2, $d3) | select -Unique | ?{ Test-Path $_ -PathType Container } | %{
                $arguments = '-m twine upload "{0}" {1}' -f (Join-Path $_ '*'), $args
                Invoke-VstsTool $python $arguments -RequireExitCodeZero
            }
        }
    } finally {
        $env:TWINE_USERNAME = $null
        $env:TWINE_PASSWORD = $null
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
