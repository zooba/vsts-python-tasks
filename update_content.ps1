"Updating VSTS Task SDK"

$tasks = gci *\task.json | %{ Split-Path $_ }
$mods = $tasks | %{ Join-Path $_ "ps_modules" }

$mods | ?{ Test-Path $_ } | %{ rmdir -Recurse -Force $_ }
mkdir $mods | Out-Null

$p = mkdir ps_modules -Force
" - created $p..."

Save-Module -Name VstsTaskSdk -RequiredVersion 0.10.0 -Path $p
" - installed VstsTaskSdk to $p..."

$mods | %{ copy "$p\VstsTaskSdk\0.10.0\*" (mkdir $_\VstsTaskSdk) }
" - copied VstsTaskSdk to modules..."

rmdir -Recurse -Force $p
" - removed VstsTaskSdk module..."

"Copy Common files"

$tasks | %{ copy "$PSScriptRoot\Common\*" $_ }
" - copied common files to modules..."
