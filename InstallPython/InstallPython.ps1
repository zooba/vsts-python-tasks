Trace-VstsEnteringInvocation $MyInvocation
try {
    $versions = Get-VstsInput -Name "versions" -Require
    $prerelease = Get-VstsInput -Name "prerelease" -AsBool
    $versionlist = Get-VstsInput -Name "versionlist"
    $outputdir = Get-VstsInput -Name "outputdir" -Default $env:BUILD_BINARIESDIRECTORY
    $dependencies = Get-VstsInput -Name "dependencies"
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

    $useBuiltinNuGetExe = $false

    if (-not $nuGetPath) {
        $useBuiltinNuGetExe = $true
        $nuGetPath = (Get-Command -Name '.\NuGet.exe' -EA 0).Source
        if (-not $nuGetPath) {
            Invoke-WebRequest https://aka.ms/nugetclidl -OutFile NuGet.exe
            $nuGetPath = (Get-Command -Name '.\NuGet.exe' -EA 0).Source
            if (-not $nuGetPath) {
                throw ("Unable to locate nuget.exe")
            }
        }
    }


    $initialNuGetExtensionsPath = $env:NUGET_EXTENSIONS_PATH

    $all_paths = "";

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

            # The only feasible way to get the install path is to check for changes
            # to the install directory. Hopefully nobody else
            $before_install = (gci $outputdir -Directory -EA 0).Name;
            Invoke-VstsTool $nuGetPath $ngArgs -RequireExitCodeZero
            $after_install = (gci $outputdir -Directory -EA 0) | `
                ?{ -not ($before_install -contains $_.Name) } | `
                %{ Join-Path $_.FullName "tools" } | `
                ?{ Test-Path (Join-Path $_ "python.exe") };

            if (-not $after_install) {
                Write-Error "Failed to install $vspec"
                return
            }

            $last_path = $after_install | select -last 1;
            if ($all_paths) {
                $all_paths = "$all_paths;$($after_install -join ';')"
            } else {
                $all_paths = $after_install -join ';'
            }

            if ($dependencies) {
                $after_install | %{
                    Invoke-VstsTool (Join-Path $_ "python.exe") "-m pip install --upgrade $dependencies" $_
                }
            }
        }
        
        Set-VstsTaskVariable -Name pythonLocation -Value $last_path
        Set-VstsTaskVariable -Name allPythonLocations -Value $all_paths
    } finally {
        $env:NUGET_EXTENSIONS_PATH = $initialNugetExtensionsPath
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
