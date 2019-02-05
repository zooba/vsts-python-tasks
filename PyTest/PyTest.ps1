Trace-VstsEnteringInvocation $MyInvocation
try {
    . $PSScriptRoot\Get-PythonExe.ps1

    $testroot = Get-VstsInput -Name "testroot"
    $patterns = (Get-VstsInput -Name "patterns" -Default "").Split()
    $packages = Get-VstsInput -Name "packages" -Default ""
    $testfilter = Get-VstsInput -Name "testfilter" -Default ""
    $resultfile = Get-VstsInput -Name "resultfile"
    $resultprefix = Get-VstsInput -Name "resultprefix" -Default "py%winver%"
    $doctests = Get-VstsInput -Name "doctests" -AsBool
    $codecoverage = Get-VstsInput -Name "codecoverage"
    $pylint = Get-VstsInput -Name "pylint" -AsBool
    $python = Get-PythonExe -Name "pythonpath"
    $dependencies = Get-VstsInput -Name "dependencies"
    $clearcache = Get-VstsInput -Name "clearcache" -AsBool
    $tempdir = Get-VstsInput -Name "tempdir"
    $abortOnFail = Get-VstsInput -Name "abortOnFail" -AsBool
    $workingdir = Get-VstsInput -Name "workingdir" -Default ""
    $otherargs = Get-VstsInput -Name "otherargs" -Default ""

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
            $args = '{0} --junitxml="{1}"' -f ($args, $resultfile)
        }
        if ($resultprefix) {
            $args = '{0} --junitprefix="{1}"' -f ($args, $resultprefix)
        }
        
        if ($codecoverage) {
            $args = '{0} {1} --cov-report=xml --cov-report=html' -f (
                $args,
                [String]::Join(' ', ($codecoverage.Split(' ,;') | %{ "--cov=$_" }))
            )
            $dependencies = '{0} pytest-cov' -f ($dependencies)
        }
        
        if ($pylint) {
            $args = '{0} --pylint' -f ($args)
            $dependencies = '{0} pytest-pylint' -f ($dependencies)
        }

        if ($packages) {
            $args = '{0} --pyargs {1}' -f ($args, $packages)
        } elseif ($testroot -and $patterns) {
            foreach ($f in Find-VstsMatch $testroot $patterns) {
                $args = '{0} "{1}"' -f ($args, $f)
            }
        }

        if ($otherargs) {
            $args = '{0} {1}' -f ($args, $otherargs)
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
                Invoke-VstsTool $python "-m pytest $args" -RequireExitCodeZero
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
