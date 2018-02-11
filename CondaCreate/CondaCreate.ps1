$prefix = Get-VstsInput -Name "prefix" -Default "${env:BUILD_BINARIESDIRECTORY}\env"
$root = Get-VstsInput -Name "root" -Default "${env:BUILD_BINARIESDIRECTORY}\conda"
$packages = Get-VstsInput -Name "packages" -Require
$clean = Get-VstsInput -Name "clean" -AsBool

if ($clean) {
    rmdir $prefix -Recurse -Force -EA 0
    rmdir $root -Recurse -Force -EA 0
}

if (-not (Test-Path "$root\python-conda\tools\conda.exe")) {
    $nuGetPath = (Get-Command -Name 'nuget' -EA 0).Source
    $nuGetPath = (Get-Command -Name '.\nuget.exe' -EA 0).Source
    if (-not $nuGetPath) {
        Invoke-WebRequest https://aka.ms/nugetclidl -OutFile nuget.exe
        $nuGetPath = (Get-Command -Name '.\nuget.exe' -EA 0).Source
        if (-not $nuGetPath) {
            throw ("Unable to locate nuget.exe")
        }
    }

    Write-Verbose "Installing conda"
    Invoke-VstsTool $nuGetPath "install -OutputDirectory `"$root`" -Source https://www.myget.org/F/python-conda/api/v3/index.json -ExcludeVersion -NonInteractive python-conda" -RequireExitCodeZero
}

Write-Verbose "Creating $prefix with $packages"

$condaArgs = "create -q -p `"$prefix`" $packages"

Invoke-VstsTool "$root\python-conda\tools\conda.exe" $condaArgs -RequireExitCodeZero
