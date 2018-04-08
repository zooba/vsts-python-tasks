function Get-PythonExe {
    [CmdletBinding()]
    param ([switch]$All,
           [string]$Name="python",
           [string]$ExeName="python.exe",
           [string]$Default="")

    Trace-VstsEnteringInvocation $MyInvocation

    try {
        $python = Get-VstsInput -Name $Name

        if (-not $python) {
            if ($All) {
                $python = Get-VstsTaskVariable -Name "InstallPython.allPythonLocations"
            } else {
                $python = Get-VstsTaskVariable -Name "InstallPython.pythonLocation"
                if (-not $python) {
                    $python = Get-VstsTaskVariable -Name "UsePythonVersion.pythonLocation"
                }
            }
        }

        if ($python) {
            return ($python -split ';') | %{
                if (Test-Path $_ -PathType Leaf) {
                    return $_
                } elseif (Test-Path (Join-Path $_ $ExeName) -PathType Leaf) {
                    return Join-Path $_ $ExeName
                }
            } | select -Unique
        }

        if ($Default) {
            return $Default
        }
        Write-Error "Failed to find Python version to use."
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}