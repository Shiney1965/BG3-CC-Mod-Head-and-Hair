$ErrorActionPreference = 'Stop'
$build   = 'C:\Users\Alan\OneDrive\Claude Projects\BG3 Mods\CCNS_v2_VanillaPath'
$stage   = Join-Path $env:TEMP 'CCNS_v2_stage'
$divine  = 'C:\bg3-sidecar-work\Tools\Divine.exe'
$gameMods = "$env:LOCALAPPDATA\Larian Studios\Baldur's Gate 3\Mods"
$pakName = 'CCNS_HairHeadSearch.pak'
$gamePak = 'C:\Steam Library\steamapps\common\Baldurs Gate 3\Data\Game.pak'

if (-not (Test-Path $divine)) { $divine = 'C:\Users\Alan\OneDrive\Claude Projects\BG3 Mods\CompatibleBodiesTooltip-1.2.0\sidecar\tools\Divine.exe' }
Write-Output "DIVINE=$divine"

# Base-freshness check: Game.pak mtime (extract was byte-verified 2026-06-01)
$gp = Get-Item -LiteralPath $gamePak
Write-Output ("GAMEPAK_MTIME={0:yyyy-MM-dd HH:mm:ss} SIZE={1}" -f $gp.LastWriteTime, $gp.Length)

# Stage a clean copy (Mods + Public only)
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Path $stage | Out-Null
Copy-Item -LiteralPath (Join-Path $build 'Mods')   -Destination $stage -Recurse
Copy-Item -LiteralPath (Join-Path $build 'Public') -Destination $stage -Recurse
Write-Output "STAGED:"
Get-ChildItem -Recurse -File $stage | ForEach-Object { Write-Output ("  {0}  {1}B" -f $_.FullName.Substring($stage.Length+1), $_.Length) }

# Pack straight into the game Mods folder
$dest = Join-Path $gameMods $pakName
& $divine --action create-package --game bg3 --source $stage --destination $dest --loglevel info
Write-Output "DIVINE_EXIT=$LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { throw "Divine failed" }

# Verify installed pak + list contents
$f = Get-Item -LiteralPath $dest
Write-Output ("INSTALLED={0} SIZE={1} MTIME={2:yyyy-MM-dd HH:mm:ss}" -f $f.FullName, $f.Length, $f.LastWriteTime)
Write-Output ("SHA256=" + (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash)
& $divine --action list-package --game bg3 --source $dest
Write-Output "LIST_EXIT=$LASTEXITCODE"

# Copy pak back to build folder so workspace copy matches installed
Copy-Item -LiteralPath $dest -Destination (Join-Path $build $pakName) -Force
Write-Output "BUILD_COPY_DONE"

Remove-Item -Recurse -Force $stage
Write-Output "ALL_DONE"
