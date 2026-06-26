# Install — CCNS (CC Hair & Head Search)

CCNS installs like a normal `.pak` mod, with one important step: it must be **active in your load order**, not just present in the Mods folder, so its Script Extender script runs. The whole process takes a couple of minutes.

## Prerequisites

1. **Baldur's Gate 3**, Patch 8 or later.
2. **BG3 Script Extender (BG3SE)** installed and working (version 29 or later). If you don't have it, get it from <https://bg3.community/> — the installation guide is on their site. When BG3 launches with Script Extender active, you'll see its console window.
3. **BG3 ImprovedUI (ImpUI)** — the Patch 8 fork, NexusMods mod **16649** (*ImpUI_P8_Fork*). Install and enable it **before** CCNS.
4. **BG3 Mod Manager (BG3MM)** — strongly recommended. You can get it from its NexusMods page. CCNS needs to be in your active load order, and a mod manager makes that one click.

## Install

1. **Download and unzip** `CCNS-1.0.0.zip`. Inside you'll find `CCNS_HairHeadSearch.pak` plus these documents.

2. **Copy the `.pak` into your BG3 Mods folder.** Open File Explorer, paste this into the address bar, and press Enter:
   ```
   %LocalAppData%\Larian Studios\Baldur's Gate 3\Mods
   ```
   Copy `CCNS_HairHeadSearch.pak` into that folder.

3. **Activate it in your load order.** Open BG3 Mod Manager and refresh its mod list (`F5` or the refresh button).
   - If **"CCNS Hair & Head Search"** appears in the right-hand **Inactive/Overrides** pane, **drag it into the left-hand Active list** (or right-click it and choose **"Add to Load Order"**).
   - This step matters: CCNS overrides a base-game UI file, so a mod manager may park it in the Overrides pane by default. While it's there, the visual labels load **but the Script Extender script — which provides the mod names, tile numbers, and search panel — does not run.** It must be in the **active** list.
   - Click **Save** to write your load order.

4. **Launch BG3.** Start a New Game and go to the appearance step (or open the Magic Mirror in-game). Open the hair or head grid — you should see a name and source-mod under each tile, numbers on modded tiles, and the search panel (it auto-opens in New Game character creation, or press `Ctrl + Shift + H`).

## Using it

- **Open / close the search panel:** `Ctrl + Shift + H` on any character-creation screen. It also opens automatically when you enter New Game character creation.
- **Search:** type in the panel's box to filter by hair/head **name** or **source mod**.
- **Apply a result:** click it — the hair/head changes immediately.
- **Walk through matches:** **Previous / Next** buttons; the status line shows the match number and the tile number to look for in the grid.
- **Console fallback:** if the hotkey is ever unavailable, open the Script Extender console, type `client` to switch to the client context, then run:
  ```
  Mods.CCNS_HairHeadSearch.CCNS_Search()
  ```

## Troubleshooting

### No labels, no numbers, no panel — nothing changed

- Confirm **Script Extender is loaded** (its console window appears when BG3 runs). Without it, CCNS does nothing.
- Confirm **CCNS is in your active load order**, not the Overrides pane (see step 3 above). This is the single most common cause.
- Confirm **ImprovedUI (mod 16649)** is installed and enabled.

### Labels show, but the panel lists everything as "Vanilla"

- The Script Extender script isn't running, or hasn't run yet. Make sure CCNS is **active in load order** (step 3) and launch the game at least once after enabling it.
- Check the Script Extender console for lines beginning with `[CCNS]`. If they're absent, the script isn't loading — re-check load order.

### The `Ctrl + Shift + H` hotkey does nothing

- Use the console fallback: `Mods.CCNS_HairHeadSearch.CCNS_Search()` (in the client context).
- If the console command works but the hotkey doesn't, another mod may be binding `Ctrl + Shift + H`.

### Labels don't appear, or appear wrong, after installing another UI mod

- Another mod may be replacing `CCLib_k.xaml` or `CCLib_c.xaml`. Only one such override can win, decided by load order. Most notably, **Customizer's Compendium (mod 10)** conflicts; use the **Patch 7 Ready** version (mod **12111**) instead. Put CCNS after other UI mods in your load order if you want it to win.

### Controller: labels don't show

- The game loads the controller UI only while you're actually using a gamepad. Switch to your controller and reopen the hair/head grid.

## Uninstalling

1. Delete `CCNS_HairHeadSearch.pak` from your BG3 Mods folder (`%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods`), or remove it in your mod manager.
2. Launch BG3 — the hair/head pickers return to their original look on next launch.

All of CCNS's changes are runtime-only. Uninstalling makes **no permanent change** to your save or your game files.
