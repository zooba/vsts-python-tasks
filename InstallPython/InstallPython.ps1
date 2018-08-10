Trace-VstsEnteringInvocation $MyInvocation
try {
    $version = Get-VstsInput -Name "version" -Default "python"
    $prerelease = Get-VstsInput -Name "prerelease" -AsBool
    $outputdir = Get-VstsInput -Name "outputdir" -Default "$env:AGENT_TOOLSDIRECTORY\PythonNuget"
    $dependencies = Get-VstsInput -Name "dependencies"
    $nuGetAdditionalArgs = Get-VstsInput -Name "nuGetAdditionalArgs"

    $nugetPath = (Get-Command 'nuget.exe' -EA 0).Definition
    if (-not $nugetPath) {
        if (Test-Path "$env:AGENT_TOOLSDIRECTORY\nuget") {
            $nugetPath = (gci "$env:AGENT_TOOLSDIRECTORY\nuget" -Directory) | `
                sort -Descending | `
                %{ Join-Path (Join-Path $_ 'x64'), (Join-Path $_ 'x86') 'nuget.exe' } | `
                ?{ Test-Path $_ } | `
                select -First 1
        }
    }
    if (-not $nugetPath) {
        Invoke-WebRequest https://aka.ms/nugetclidl -OutFile nuget.exe
        $nugetPath = (Get-Command '.\nuget.exe' -EA 0).Definition
    }
    if (-not $nugetPath) {
        throw "Unable to locate nuget.exe. Use the Nuget Tool Installer task to ensure it is available."
    }

    if ($env:NUGET_EXTENSIONS_PATH) {
        Write-Host "Detected NuGet extensions loader path. Environment variable NUGET_EXTENSIONS_PATH is set to: $env:NUGET_EXTENSIONS_PATH"
    }

    Write-Verbose "Installing $version to $outputdir"

    $ngArgs = 'install -OutputDirectory "{0}" {1}' -f $outputdir, $nuGetAdditionalArgs

    if ($prerelease -ieq "true") {
        $ngArgs = "$ngArgs -Prerelease";
    }

    if ($version -match 'pythondaily') {
        $ngArgs = "$ngArgs -FallbackSource https://www.myget.org/F/python/api/v3/index.json";
    }

    if ($version -match '^(.+?)==(.+)$') {
        $ngArgs = "$ngArgs $($Matches[1]) -Version $($Matches[2])";
    } else {
        $ngArgs = "$ngArgs $version";
    }

    # The only feasible way to get the install path is to check for changes
    # to the install directory. Hopefully nobody else installs something
    # simultaneously.
    $before_install = (gci $outputdir -Directory -EA 0).Name;
    Invoke-VstsTool $nuGetPath $ngArgs -RequireExitCodeZero
    $after_install = (gci $outputdir -Directory -EA 0) | `
        ?{ -not ($before_install -contains $_.Name) } | `
        %{ Join-Path $_.FullName "tools" } | `
        ?{ Test-Path (Join-Path $_ "python.exe") };

    if (-not $after_install) {
        if ($version -match '^(.+?)==(.+)$') {
            $p = "$($Matches[1]).$($Matches[2])";
        } else {
            $p = "${version}."
        }
        $after_install = (gci $outputdir -Directory -EA 0) | `
            ?{ $_.Name.StartsWith($p) } | `
            %{ Join-Path $_.FullName "tools" } | `
            ?{ Test-Path (Join-Path $_ "python.exe") } | `
            select -last 1;
    }
    if (-not $after_install) {
        Write-Error "Failed to install $version"
        return
    }

    $last_path = $after_install | select -last 1;
    if ($after_install.Count -gt 1) {
        Write-Host "Multiple installs were detected - using $last_path"
        Write-Verbose "Detected $after_install"
    }

    Set-VstsTaskVariable -Name pythonLocation -Value $last_path
    $env:PATH = '{0};{1}' -f ($env:PATH, $last_path)
    Write-Host "##vso[task.prependpath]$last_path"

    $script_path = Join-Path $last_path "Scripts"
    $env:PATH = '{0};{1}' -f ($env:PATH, $script_path)
    Write-Host "##vso[task.prependpath]$script_path"

    if ($dependencies) {
        Invoke-VstsTool (Join-Path $last_path "python.exe") "-m pip install --upgrade $dependencies" $last_path
    }
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
