$ErrorActionPreference = 'Stop'
$divine   = 'C:\bg3-sidecar-work\Tools\Divine.exe'
$srcDir   = 'C:\Users\Alan\OneDrive\Claude Projects\BG3 Mods\CCNS\_v7_work\extracted_v11_8'
$vanC     = 'C:\bg3-sidecar-work\_ccns_c_extract\CCLib_c.vanilla.xaml'
$buildPak = 'C:\Users\Alan\OneDrive\Claude Projects\BG3 Mods\CCNS\CCNS_ModSourceSpike\CCNS_HairHeadSearch.pak'
$gameMods = "$env:LOCALAPPDATA\Larian Studios\Baldur's Gate 3\Mods\CCNS_HairHeadSearch.pak"
$archive  = 'C:\Users\Alan\OneDrive\Claude Projects\BG3 Mods\CCNS\Prior Build Paks\CCNS_searchpanel_v11_8_2026-06-26.pak'
$backup   = 'C:\Users\Alan\OneDrive\Claude Projects\BG3 Mods\CCNS\Prior Build Paks\CCNS_INSTALLED_backup_before_v11_8_2026-06-26.pak'
$luac     = "$env:LOCALAPPDATA\Programs\Lua\bin\luac.exe"
$lua      = "$srcDir\Mods\CCNS_HairHeadSearch_a1f4c9e2-7b3d-4e8a-9c6f-2d5e8b1a4c70\ScriptExtender\Lua\BootstrapClient.lua"
$xamlK    = "$srcDir\Public\Game\GUI\Library\CCLib_k.xaml"
$xamlC    = "$srcDir\Public\Game\GUI\Library\CCLib_c.xaml"

# --- 1. Keyboard guard: must be byte-identical v11.7 (466457 B, CRLF clean) ---
$kraw = [System.IO.File]::ReadAllText($xamlK)
$ksize = (Get-Item $xamlK).Length
$klf = ([regex]::Matches($kraw, "(?<!`r)`n")).Count
Write-Output ("K_SIZE=" + $ksize + " K_LONE_LF=" + $klf + " (expect 466457 / 0)")
if ($ksize -ne 466457 -or $klf -ne 0) { throw "KEYBOARD fidelity FAILED -- aborting." }

# --- 2. Controller: normalize to CRLF, then validate ---
$craw = [System.IO.File]::ReadAllText($xamlC)
$craw = ($craw -replace "`r`n", "`n") -replace "`n", "`r`n"
[System.IO.File]::WriteAllText($xamlC, $craw, (New-Object System.Text.UTF8Encoding($false)))
$clf = ([regex]::Matches($craw, "(?<!`r)`n")).Count
Write-Output ("C_LONE_LF=" + $clf + " (expect 0)")
if ($clf -ne 0) { throw "CONTROLLER CRLF normalize FAILED." }

# XML well-formed?
try { [xml]$null = Get-Content -LiteralPath $xamlC -Raw; Write-Output "C_XML=WELLFORMED" }
catch { throw ("CONTROLLER XML PARSE FAILED: " + $_.Exception.Message) }

# Token presence
foreach ($t in 'x:Name="CCNS_LabelBack"','x:Name="CCNS_NameLabel"','Value="SelectableHair"','Value="SelectableHeads"') {
  $n = (Select-String -LiteralPath $xamlC -Pattern $t -SimpleMatch -AllMatches | Measure-Object).Count
  Write-Output ("TOKEN " + $t + " = " + $n)
  if ($n -lt 1) { throw ("MISSING TOKEN: " + $t) }
}

# Diff vs vanilla _c: expect exactly +8 added lines, 0 removed
$vanLines = Get-Content -LiteralPath $vanC
$newLines = Get-Content -LiteralPath $xamlC
$added   = (Compare-Object $vanLines $newLines | Where-Object { $_.SideIndicator -eq '=>' }).Count
$removed = (Compare-Object $vanLines $newLines | Where-Object { $_.SideIndicator -eq '<=' }).Count
Write-Output ("C_DIFF added=" + $added + " removed=" + $removed + " (expect 10 / 0); vanLines=" + $vanLines.Count + " newLines=" + $newLines.Count)
if ($added -ne 10 -or $removed -ne 0) { throw "CONTROLLER diff vs vanilla unexpected -- aborting." }

# --- 3. Lua syntax check ---
if (Test-Path $luac) {
  & $luac -p $lua
  Write-Output ("LUAC_EXIT=" + $LASTEXITCODE)
  if ($LASTEXITCODE -ne 0) { throw "Lua luac -p FAILED." }
} else { Write-Output "LUAC=NOT_FOUND (skipped)" }

# --- 4. Pack ---
& $divine --action create-package --game bg3 --source $srcDir --destination $buildPak --compression-method lz4
Write-Output ("DIVINE_EXIT=" + $LASTEXITCODE)
if ($LASTEXITCODE -ne 0) { throw "create-package failed" }
Write-Output "=== list-package ==="
& $divine --action list-package --game bg3 --source $buildPak
$size = (Get-Item $buildPak).Length
$hash = (Get-FileHash $buildPak -Algorithm SHA256).Hash
Write-Output ("BUILD_PAK_SIZE=" + $size)
Write-Output ("BUILD_PAK_SHA256=" + $hash)
Copy-Item $buildPak $archive -Force
Write-Output ("archived -> " + $archive)

# --- 5. Install if game closed ---
$running = Get-Process -Name bg3, bg3_dx11 -ErrorAction SilentlyContinue
if ($running) {
  Write-Output "GAME_RUNNING=YES -- install SKIPPED. Close BG3 and run install_v11_8.ps1."
} else {
  if (Test-Path $gameMods) { Copy-Item $gameMods $backup -Force; Write-Output ("backed up installed pak -> " + $backup) }
  Copy-Item $buildPak $gameMods -Force
  $ih = (Get-FileHash $gameMods -Algorithm SHA256).Hash
  if ($ih -eq $hash) { Write-Output "INSTALL_VERIFIED=GREEN" } else { Write-Output "INSTALL_VERIFIED=MISMATCH" }
}
