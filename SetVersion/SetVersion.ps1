$version = Get-VstsInput -Name "version" -Require
$root = Get-VstsInput -Name "root" -Default ""
$patterns = (Get-VstsInput -Name "patterns" -Require).Split()
$encoding = Get-VstsInput -Name "encoding" -Default "utf8"

if ($encoding -ieq "utf8") {
    $enc = [System.Text.UTF8Encoding]::new($false)
} elseif ($encoding -ieq "utf8sig") {
    $enc = [System.Text.UTF8Encoding]::new($true)
} elseif ($encoding -ieq "utf16le") {
    $enc = [System.Text.UnicodeEncoding]::new($false)
} elseif ($encoding -ieq "utf16sig") {
    $enc = [System.Text.UnicodeEncoding]::new($true)
} else {
    $enc = [System.Text.ASCIIEncoding]::new()
}

$pat = '(__version__\s*=\s*)(' + "'.*'" + '|".*")'
$repl = '$1' + "'$version'"

foreach ($f in Find-VstsMatch $root $patterns) {
    $c = [IO.File]::ReadAllText($f, $enc)
    $c2 = $c -replace $pat, $repl
    if ($c -ne $c2) {
        [IO.File]::WriteAllText($f, $c2, $enc)
        Write-Verbose "Updated $f"
    } else {
        Write-Verbose "Not updating $f because nothing changed"
    }
}
