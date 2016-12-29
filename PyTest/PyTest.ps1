$testroot = Get-VstsInput -Name "testroot"
$patterns = (Get-VstsInput -Name "patterns" -Default "").Split()
$testfilter = Get-VstsInput -Name "testfilter" -Default ""
$resultfile = Get-VstsInput -Name "resultfile" -Default "test-results.xml"
$doctests = Get-VstsInput -Name "doctests" -AsBool
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"
$clearcache = Get-VstsInput -Name "clearcache" -AsBool
$tempdir = Get-VstsInput -Name "tempdir"

if (Test-Path $python) {
    $pythons = @($python)
} else {
    $pythons = gci $python -File -Recurse
}

if ($dependencies) {
    foreach($py in $pythons) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }
}

$args = "--color=no --full-trace -q"
if ($testfilter) {
    $args = "$args -k `"$testfilter`""
}

pushd $env:SYSTEM_DEFAULTWORKINGDIRECTORY
try {
    if ($tempdir) {
        $args = "$args --basetemp=`"$(mkdir $tempdir -Force)`""
    }

    if ($resultfile) {
        $resultfile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($resultfile)
        $rfparent = Split-Path $resultfile
        if ($rfparent) {
            mkdir $rfparent -Force | Out-Null
        }
        $args = "$args --junit-xml=`"$resultfile`""
    }

    if ($testroot -and $patterns) {
        foreach ($f in Find-VstsMatch $testroot $patterns) {
            $args = "$args `"$f`""
        }
    }

    if ($testroot) {
        cd $testroot
    }

    foreach($py in $pythons) {
        Invoke-VstsTool $py "-m pytest $args"
    }
} finally {
    popd
}