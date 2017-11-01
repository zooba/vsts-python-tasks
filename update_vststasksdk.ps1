$mods = gci *\task.json | %{ Join-Path (Split-Path $_) "ps_modules" }

$mods | ?{ Test-Path $_ } | %{ rmdir -Recurse -Force $_ }
mkdir $mods | Out-Null

$p = mkdir ps_modules -Force
"Created $p..."

Save-Module -Name VstsTaskSdk -RequiredVersion 0.10.0 -Path $p
"Installed VstsTaskSdk to $p..."

$mods | %{ copy "$p\VstsTaskSdk\0.10.0\*" (mkdir $_\VstsTaskSdk) }
"Copied VstsTaskSdk to modules..."

rmdir -Recurse -Force $p
"Removed VstsTaskSdk module..."
