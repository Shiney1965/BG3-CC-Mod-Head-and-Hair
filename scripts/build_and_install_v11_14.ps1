$ErrorActionPreference = 'Stop'
$divine   = 'C:\bg3-sidecar-work\Tools\Divine.exe'
$srcDir   = 'C:\Claude Projects\BG3 Mods\CCNS\_v7_work\extracted_v11_14'
$buildPak = 'C:\Claude Projects\BG3 Mods\CCNS\CCNS_ModSourceSpike\CCNS_HairHeadSearch.pak'
$archive  = 'C:\Claude Projects\BG3 Mods\CCNS\Prior Build Paks\CCNS_searchpanel_v11_14_2026-08-30.pak'
$cFolder  = 'C:\Claude Projects\BG3 Mods\CCNS\CCNS_HairHeadSearch_v11_14.pak'
$luac     = "$env:LOCALAPPDATA\Programs\Lua\bin\luac.exe"
$modDir   = "$srcDir\Mods\CCNS_HairHeadSearch_a1f4c9e2-7b3d-4e8a-9c6f-2d5e8b1a4c70"
$lua      = "$modDir\ScriptExtender\Lua\BootstrapClient.lua"
$meta     = "$modDir\meta.lsx"
$xamlK    = "$srcDir\Public\Game\GUI\Library\CCLib_k.xaml"
$xamlC    = "$srcDir\Public\Game\GUI\Library\CCLib_c.xaml"

# --- 0. BG3 must be closed ---
$bg = Get-Process bg3, bg3_dx11 -ErrorAction SilentlyContinue
if ($bg) { throw ("BG3 IS RUNNING (" + ($bg.ProcessName -join ',') + ") -- close it and re-run.") }
Write-Output "BG3_NOT_RUNNING = OK"

# --- 1. XAML fidelity (v11.14 is Lua-only; XAML byte-identical to the v11.9 baseline) ---
$ksize = (Get-Item $xamlK).Length; $csize = (Get-Item $xamlC).Length
$klf = ([regex]::Matches([System.IO.File]::ReadAllText($xamlK), "(?<!`r)`n")).Count
$clf = ([regex]::Matches([System.IO.File]::ReadAllText($xamlC), "(?<!`r)`n")).Count
Write-Output ("K_SIZE=" + $ksize + " K_LONE_LF=" + $klf + " (expect 466457 / 0)")
Write-Output ("C_SIZE=" + $csize + " C_LONE_LF=" + $clf + " (expect 499966 / 0)")
if ($ksize -ne 466457 -or $klf -ne 0) { throw "KEYBOARD XAML changed -- aborting." }
if ($csize -ne 499966 -or $clf -ne 0) { throw "CONTROLLER XAML changed -- aborting." }

# --- 2. meta.lsx author guard (unchanged from v11.12/v11.13) ---
if (-not (Select-String -LiteralPath $meta -Pattern 'value="Serpentine (NexusMods: SerpentineShel)"' -SimpleMatch -Quiet)) { throw "meta.lsx Author is NOT the Serpentine value -- aborting." }
if (Select-String -LiteralPath $meta -Pattern 'Alan + Claude' -SimpleMatch -Quiet) { throw "meta.lsx still contains old author 'Alan + Claude' -- aborting." }
Write-Output "META AUTHOR GUARD PASSED"

# --- 3. Lua syntax + POSITIVE tokens ---
if (Test-Path $luac) { & $luac -p $lua; Write-Output ("LUAC_EXIT=" + $LASTEXITCODE); if ($LASTEXITCODE -ne 0) { throw "luac -p FAILED." } } else { Write-Output "LUAC=NOT_FOUND (skipped)" }
foreach ($t in 'HOTKEY-ONLY','v11.14 loaded','togglePanel','Ext.Events.KeyInput','Ext.Events.StatsLoaded','vanilla tiles are numbered too','function showCurrent()','Show current Head/Hair') {
  $n = (Select-String -LiteralPath $lua -Pattern $t -SimpleMatch -AllMatches | Measure-Object).Count
  Write-Output ("LUA +TOKEN " + $t + " = " + $n); if ($n -lt 1) { throw ("MISSING token: " + $t) }
}
# --- 3b. NEGATIVE tokens (heartbeat gone; old version banner gone) ---
foreach ($t in 'Ext.Events.Tick','GameStateChanged:Subscribe','autoTick','CCNS_ProbeBaseline','v11.13 loaded','modded-only; nil = base/vanilla -> skip') {
  $n = (Select-String -LiteralPath $lua -Pattern $t -SimpleMatch -AllMatches | Measure-Object).Count
  Write-Output ("LUA -TOKEN " + $t + " = " + $n); if ($n -ne 0) { throw ("FORBIDDEN token present: " + $t) }
}

# --- 4. Pack ---
& $divine --action create-package --game bg3 --source $srcDir --destination $buildPak --compression-method lz4
if ($LASTEXITCODE -ne 0) { throw "create-package failed" }
$hash = (Get-FileHash $buildPak -Algorithm SHA256).Hash
Write-Output ("BUILD_PAK_SIZE=" + (Get-Item $buildPak).Length)
Write-Output ("BUILD_PAK_SHA256=" + $hash)

# --- 5. Copies + install (replaces v11.13) ---
Copy-Item $buildPak $archive -Force
Copy-Item $buildPak $cFolder -Force
$modsDir = Join-Path $env:LOCALAPPDATA 'Larian Studios\Baldur''s Gate 3\Mods'
$target  = Join-Path $modsDir 'CCNS_HairHeadSearch.pak'
$prev = if (Test-Path $target) { (Get-FileHash $target -Algorithm SHA256).Hash } else { 'NONE' }
Copy-Item $buildPak $target -Force
$now = (Get-FileHash $target -Algorithm SHA256).Hash
Write-Output ("PREV_INSTALLED_SHA = " + $prev)
Write-Output ("NOW_INSTALLED_SHA  = " + $now)
Write-Output ("INSTALL_MATCH      = " + ($now -eq $hash))
Write-Output ("INSTALLED_PATH     = " + $target)
Write-Output "DONE."
