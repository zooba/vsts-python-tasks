param(
    [string]$versions,
    [string]$prerelease,
    [string]$versionlist,
    [string]$outputdir,
    [string]$nuGetAdditionalArgs,
    [string]$nuGetPath,
    [string]$nuGetSource,
    [string]$clean
)

$initialNuGetExtensionsPath = $env:NUGET_EXTENSIONS_PATH

try {
    if ($versionlist) {
        $versions = $versionlist
    }

    if (-not $outputdir) {
        $outputdir = $env:BUILD_BINARIESDIRECTORY
    }

    if ($clean -ieq "true") {
        rmdir "$outputdir\python*" -Recurse -Force
    }

    $useBuiltinNuGetExe = !$nuGetPath

    if($useBuiltinNuGetExe) {
        $nuGetPath = Get-ToolPath -Name 'NuGet.exe';
    }

    if (-not $nuGetPath) {
        throw ("Unable to locate nuget.exe")
    }

    if ($env:NUGET_EXTENSIONS_PATH) {
        if($useBuiltinNuGetExe) {
            # NuGet.exe extensions only work with a single specific version of nuget.exe. This causes problems
            # whenever we update nuget.exe on the agent.
            $env:NUGET_EXTENSIONS_PATH = $null
            Write-Warning (Get-LocalizedString -Key "The NUGET_EXTENSIONS_PATH environment variable is set, but nuget.exe extensions are not supported when using the built-in NuGet implementation.")   
        } else {
            Write-Host (Get-LocalizedString -Key "Detected NuGet extensions loader path. Environment variable NUGET_EXTENSIONS_PATH is set to: {0}" -ArgumentList $env:NUGET_EXTENSIONS_PATH)
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
        
        if ($vspec -match '^(.+?)==(.+)$') {
            $ngArgs = "$ngArgs $($Matches[1]) -Version $($Matches[2])";
        } else {
            $ngArgs = "$ngArgs $vspec";
        }
        
        Write-Verbose "Invoking nuget with $ngArgs"
        Invoke-Tool -Path $nuGetPath -Arguments $ngArgs
    }
} finally {
    $env:NUGET_EXTENSIONS_PATH = $initialNugetExtensionsPath
}

