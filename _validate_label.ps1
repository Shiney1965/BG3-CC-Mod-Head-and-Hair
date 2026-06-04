$root = 'C:\bg3-sidecar-work\CCNS'
$files = @(
  'label_swap\Mods\CCNS_HairHeadSearch_a1f4c9e2-7b3d-4e8a-9c6f-2d5e8b1a4c70\GUI\Library\Lib_Keyboard.xaml',
  'label_swap\Mods\CCNS_HairHeadSearch_a1f4c9e2-7b3d-4e8a-9c6f-2d5e8b1a4c70\GUI\Library\Lib_Controller.xaml',
  'label_swap\Mods\CCNS_HairHeadSearch_a1f4c9e2-7b3d-4e8a-9c6f-2d5e8b1a4c70\meta.lsx'
)
foreach ($f in $files) {
  $p = Join-Path $root $f
  try { [xml]$null = Get-Content -LiteralPath $p -Raw; Write-Output ("XML_OK  $f") }
  catch { Write-Output ("XML_FAIL $f :: " + $_.Exception.Message) }
}
