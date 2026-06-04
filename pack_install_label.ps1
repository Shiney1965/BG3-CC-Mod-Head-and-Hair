$ErrorActionPreference = 'Stop'
$divine = 'C:\bg3-sidecar-work\tools\Divine.exe'
$src    = 'C:\bg3-sidecar-work\CCNS\label_swap'
$build  = 'C:\bg3-sidecar-work\CCNS\build\CCNS_HairHeadSearch_label.pak'
$mods   = Join-Path $env:LocalAppData "Larian Studios\Baldur's Gate 3\Mods"
$dest   = Join-Path $mods 'CCNS_HairHeadSearch.pak'

Write-Output ("divine_exists=" + (Test-Path -LiteralPath $divine))
Write-Output ("mods_dir_exists=" + (Test-Path -LiteralPath $mods))

& $divine --action create-package --game bg3 --source $src --destination $build --loglevel info
Write-Output ("pack_exit=" + $LASTEXITCODE)

if ($LASTEXITCODE -eq 0) {
    Copy-Item -LiteralPath $build -Destination $dest -Force
    $f = Get-Item -LiteralPath $dest
    Write-Output ("installed_path=" + $f.FullName)
    Write-Output ("installed_size=" + $f.Length)
    Write-Output ("installed_mtime=" + $f.LastWriteTime)
    Write-Output ("sha256=" + (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash)
}
