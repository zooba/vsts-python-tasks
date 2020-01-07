Trace-VstsEnteringInvocation $MyInvocation
try {
    $version = Get-VstsInput -Name "version" -Default "3.8"
    $dependencies = Get-VstsInput -Name "dependencies"

    if ($version.Length -gt 3) {
        $shortversion = $version.SubString(0, 3)
    } else {
        $shortversion = $version
    }

    $package = gci "$PSScriptRoot\msix\python-$version*.msix" | sort -Desc | select -First 1

    Write-Verbose "Installing $($package.Name)"

    Add-AppxPackage $package.FullName -ForceUpdateFromAnyVersion
    $pfn = (Get-AppxPackage "PythonSoftwareFoundation.Python.$version*" | sort -Desc Version | select -First 1).PackageFamilyName

    $py_path = "${env:LocalAppData}\Microsoft\WindowsApps\$pfn"
    if (Test-Path $py_path) {
        Set-VstsTaskVariable -Name pythonLocation -Value $last_path
        $env:PATH = '{1};{0}' -f ($env:PATH, $py_path)
        Write-Host "##vso[task.prependpath]$py_path"

        $site_path = & "$py_path\python.exe" -m site --user-site
        if ($? -and $site_path -and (Test-Path $site_path)) {
            $script_path = Join-Path (Split-Path -Parent $site_path) "Scripts"
            $env:PATH = '{1};{0}' -f ($env:PATH, $script_path)
            Write-Host "##vso[task.prependpath]$script_path"

    if ($dependencies) {
        Invoke-VstsTool (Join-Path $py_path "pip.exe") "install --upgrade $dependencies"
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}