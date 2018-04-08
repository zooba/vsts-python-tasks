function Get-PythonExe {
    [CmdletBinding()]
    param ([switch]$All,
           [string]$Name="python",
           [string]$ExeName="python.exe",
           [string]$Default="")

    Trace-VstsEnteringInvocation $MyInvocation

    try {
        $python = Get-VstsInput -Name $InputName
        if (-not $python) {
            $python = Get-VstsTaskVariable -Name "UsePythonVersion.pythonLocation"
        }
        if (-not $python) {
            $python = Get-VstsTaskVariable -Name "InstallPython.pythonLocation"
        }
        if ($python) {
            if (Test-Path $python -PathType Leaf) {
                return $python
            }
            $python = Join-Path $python $ExeName
            if (Test-Path $python -PathType Leaf) {
                return $python
            }
        }
        if ($Default) {
            return $Default
        }
        Write-Error "Failed to find Python version to use"
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}