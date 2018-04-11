function Get-PythonExe {
    [CmdletBinding()]
    param ([string]$Name="python",
           [string]$ExeName="python.exe",
           [string]$Default="")

    Trace-VstsEnteringInvocation $MyInvocation

    try {
        $python = Get-VstsInput -Name $Name

        if ($python) {
            return ($python -split ';') | %{
                if (Test-Path $_ -PathType Leaf) {
                    return $_
                } elseif (Test-Path (Join-Path $_ $ExeName) -PathType Leaf) {
                    return Join-Path $_ $ExeName
                }
            } | select -First 1
        }

        $python = (Get-Command $ExeName -EA 0).Path
        if ($python) {
            return $python
        }

        if ($Default) {
            return $Default
        }
        Write-Error "Failed to find Python version to use."
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }
}