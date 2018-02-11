$testroot = Get-VstsInput -Name "testroot"
$patterns = (Get-VstsInput -Name "patterns" -Default "").Split()
$testfilter = Get-VstsInput -Name "testfilter" -Default ""
$resultfile = Get-VstsInput -Name "resultfile" -Default "test-py%winver%.xml"
$resultprefix = Get-VstsInput -Name "resultprefix" -Default "py%winver%"
$doctests = Get-VstsInput -Name "doctests" -AsBool
$python = Get-VstsInput -Name "python" -Require
$dependencies = Get-VstsInput -Name "dependencies"
$clearcache = Get-VstsInput -Name "clearcache" -AsBool
$tempdir = Get-VstsInput -Name "tempdir"
$abortOnFail = Get-VstsInput -Name "abortOnFail" -AsBool

$pythons = gci $python -Recurse

if ($dependencies) {
    foreach($py in $pythons) {
        Invoke-VstsTool $py "-m pip install $dependencies"
    }
}

$args = "--color=no -q"
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
        $args = "$args --junitxml=`"$resultfile`" --junitprefix=`"$resultprefix`""
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
        $env:winver = & $py -SEc "import sys;print(sys.winver)"
        try {
            if ($abortOnFail) {
                Invoke-VstsTool $py "-m pytest $args" -RequireExitCodeZero
            } else {
                Invoke-VstsTool $py "-m pytest $args"
            }
        } finally {
            $env:winver = $null
        }
    }
} finally {
    popd
}