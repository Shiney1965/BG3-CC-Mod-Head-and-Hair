# CCNS — CC Hair & Head Search

A Baldur's Gate 3 character-creation UI mod that adds **name labels** under each hair/head
picker thumbnail and a **search/filter** for them. Targets the appearance editor used by
both new-game CC and the AEE Magic Mirror / Resculpt.

## Status

Rebuild in progress (2026-06-02). Earlier builds shipped a bare `GUI/Library/CCLib_k.xaml`,
which the engine never loads — `Lib_Keyboard.xaml`/`Lib_Controller.xaml` are the real entry
points. See `docs/` and the project memory for full history.

## Layout

- `baseline/` — authoritative current-game reference XAML (vanilla `CCLib_k.xaml` / `CCLib_c.xaml`),
  tagged so every build diffs against the real current game files. Never edit; reference only.
- `src/` — the mod source tree that gets packed into the `.pak`.
- `build/` — packed `.pak` output (gitignored).

## Key facts

- Hair/head tile template: `CustomBrushIconTemplate` (vanilla `CCLib_k.xaml` L1893). No label in vanilla.
- Race/background tile template: `CustomIconTemplate` (L1822) — already has a label; not our target.
- Override mechanism (Patch 8): redeclare the affected ResourceDictionary keys via the mod's
  `GUI/Library/Lib_Keyboard.xaml` (+ `Lib_Controller.xaml`); load order wins; ImpUI auto-merges.
  Deterministic fallback: BG3SE `Ext.IO.AddPathOverride`.
- Do NOT reactivate the old `CCNS Test Stub` (broke Examine). BG3SE is not a meta.lsx dependency.
