Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $testroot = Get-VstsInput -Name "testroot"
    $patterns = (Get-VstsInput -Name "patterns" -Default "").Split()
    $testfilter = Get-VstsInput -Name "testfilter" -Default ""
    $resultfile = Get-VstsInput -Name "resultfile" -Require
    $resultprefix = Get-VstsInput -Name "resultprefix" -Default "py%winver%"
    $doctests = Get-VstsInput -Name "doctests" -AsBool
    $python = Get-PythonExe -Name "pythonpath"
    $dependencies = Get-VstsInput -Name "dependencies"
    $clearcache = Get-VstsInput -Name "clearcache" -AsBool
    $tempdir = Get-VstsInput -Name "tempdir" -Require
    $abortOnFail = Get-VstsInput -Name "abortOnFail" -AsBool
    $workingdir = Get-VstsInput -Name "workingdir" -Require

    $args = "--color=no -q"
    if ($testfilter) {
        $args = '{0} -k "{1}"' -f ($args, $testfilter)
    }

    pushd $workingdir
    try {
        if ($tempdir) {
            $args = '{0} --basetemp="{1}"' -f ($args, (mkdir $tempdir -Force))
        }

        if ($resultfile) {
            $resultfile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($resultfile)
            $rfparent = Split-Path $resultfile
            if ($rfparent) {
                mkdir $rfparent -Force | Out-Null
            }
            $args = '{0} --junitxml="{1}" --junitprefix="{2}"' -f ($args, $resultfile, $resultprefix)
        }

        if ($testroot -and $patterns) {
            foreach ($f in Find-VstsMatch $testroot $patterns) {
                $args = '{0} "{1}"' -f ($args, $f)
            }
        }

        $env:winver = & $python -SEc "import sys;print(sys.winver)"

        if ($dependencies) {
            Invoke-VstsTool $python "-m pip install $dependencies" 
        }

        if ($testroot) {
            cd $testroot
        }

        try {
            if ($abortOnFail) {
                Invoke-VstsTool $python "-m pytest $args"
                if ($LASTEXITCODE -ne 0) {
                    Write-Error "Test failures occurred. Ensure your Publish Test Results task is configured to always run, or you will not see any test results associated with this bulid."
                }
            } else {
                Invoke-VstsTool $python "-m pytest $args"
            }
        } finally {
            $env:winver = $null
        }
    } finally {
        popd
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
