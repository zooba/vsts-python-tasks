$mods = gci *\task.json | %{ Join-Path (Split-Path $_) "ps_modules" }

$mods | ?{ Test-Path $_ } | %{ rmdir -Recurse -Force $_ }
mkdir $mods | Out-Null
$mods | %{ Save-Module -Name VstsTaskSdk -RequiredVersion 0.10.0 -Path $_ }
