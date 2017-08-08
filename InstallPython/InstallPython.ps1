$versions = Get-VstsInput -Name "versions" -Require
$prerelease = Get-VstsInput -Name "prerelease" -AsBool
$versionlist = Get-VstsInput -Name "versionlist"
$outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
$nuGetAdditionalArgs = Get-VstsInput -Name "nuGetAdditionalArgs"
$nuGetPath = Get-VstsInput -Name "nuGetPath"
$nuGetSource = Get-VstsInput -Name "nuGetSource"
$clean = Get-VstsInput -Name "clean" -AsBool

if ($versionlist) {
    $versions = $versionlist
}

if ($clean) {
    rmdir "$outputdir\python*" -Recurse -Force
}

$useBuiltinNuGetExe = !$nuGetPath

if ($useBuiltinNuGetExe) {
    $nuGetPath = (Get-Command -Name '.\NuGet.exe' -EA 0).Source
}

if (-not $nuGetPath) {
    throw ("Unable to locate nuget.exe")
}

$initialNuGetExtensionsPath = $env:NUGET_EXTENSIONS_PATH

try {
    if ($env:NUGET_EXTENSIONS_PATH) {
        if($useBuiltinNuGetExe) {
            # NuGet.exe extensions only work with a single specific version of nuget.exe. This causes problems
            # whenever we update nuget.exe on the agent.
            $env:NUGET_EXTENSIONS_PATH = $null
            Write-Warning "The NUGET_EXTENSIONS_PATH environment variable is set, but nuget.exe extensions are not supported when using the built-in NuGet implementation."
        } else {
            Write-Host "Detected NuGet extensions loader path. Environment variable NUGET_EXTENSIONS_PATH is set to: $env:NUGET_EXTENSIONS_PATH"
        }
    }

    foreach ($vspec in ($versions -split ';')) {
        Write-Verbose "Installing $vspec to $outputdir"

        $ngArgs = "install -OutputDirectory `"$outputdir`" $nuGetAdditionalArgs";

        if ($prerelease -ieq "true") {
            $ngArgs = "$ngArgs -Prerelease";
        }

        if ($nuGetSource) {
            $ngArgs = "$ngArgs -Source $nuGetSource";
        }

        if ($vspec -match 'pythondaily') {
            $ngArgs = "$ngArgs -FallbackSource https://www.myget.org/F/python/api/v3/index.json";
        }

        if ($vspec -match '^(.+?)==(.+)$') {
            $ngArgs = "$ngArgs $($Matches[1]) -Version $($Matches[2])";
        } else {
            $ngArgs = "$ngArgs $vspec";
        }

        Invoke-VstsTool $nuGetPath $ngArgs -RequireExitCodeZero
    }
} finally {
    $env:NUGET_EXTENSIONS_PATH = $initialNugetExtensionsPath
}

