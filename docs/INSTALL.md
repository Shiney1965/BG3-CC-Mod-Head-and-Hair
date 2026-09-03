# Install — CCNS (CC Hair & Head Search)

CCNS installs like a normal `.pak` mod, with one important step: it must be **active in your load order**, not just present in the Mods folder, so its Script Extender script runs. The whole process takes a couple of minutes.

## Prerequisites

1. **Baldur's Gate 3**, Patch 8 or later.
2. **BG3 Script Extender (BG3SE)** installed and working (version 29 or later). If you don't have it, get it from <https://bg3.community/> — the installation guide is on their site. When BG3 launches with Script Extender active, you'll see its console window.
3. **BG3 Mod Manager (BG3MM)** — strongly recommended. You can get it from its NexusMods page. CCNS needs to be in your active load order, and a mod manager makes that one click.
4. *(Optional / recommended)* **BG3 ImprovedUI** — the Patch 8 fork, NexusMods mod **16649** (*ImpUI_P8_Fork*). Not required; CCNS runs without it, but the two are tested together.

## Install

1. **Download and unzip** `CCNS-1.1.0.zip`. Inside you'll find `CCNS_HairHeadSearch.pak` plus these documents.

2. **Copy the `.pak` into your BG3 Mods folder.** Open File Explorer, paste this into the address bar, and press Enter:
   ```
   %LocalAppData%\Larian Studios\Baldur's Gate 3\Mods
   ```
   Copy `CCNS_HairHeadSearch.pak` into that folder.

3. **Activate it in your load order.** Open BG3 Mod Manager and refresh its mod list (`F5` or the refresh button).
   - If **"CCNS Hair & Head Search"** appears in the right-hand **Inactive/Overrides** pane, **drag it into the left-hand Active list** (or right-click it and choose **"Add to Load Order"**).
   - This step matters: CCNS overrides a base-game UI file, so a mod manager may park it in the Overrides pane by default. While it's there, the visual labels load **but the Script Extender script — which provides the mod names, tile numbers, and search panel — does not run.** It must be in the **active** list.
   - Click **Save** to write your load order.

4. **Launch BG3.** Start a New Game and go to the appearance step (or open the Magic Mirror / a mid-game appearance editor). Open the **Head or Hair** grid — you should see a name and source-mod under each tile. Then press `Ctrl + Shift + H` to open the search panel.

## Using it

**➤ IMPORTANT — HOW TO GET THE THUMBNAIL NUMBERS:** press `Ctrl + Shift + H` on the **Head or Hair** screen to open the panel, then **click back and forth between the Hair and Head tabs until the numbers appear on the thumbnails in both** — usually 1–2 round trips. The numbers should then be permanently assigned; if they're ever removed during the game, repeat the round trip when you re-enter the CC panels.

- **Open / close the search panel:** `Ctrl + Shift + H`, while on the Head or Hair screen. The hotkey does nothing on other screens (by design); closing works anywhere.
- **Search:** type in the panel's box to filter by hair/head **name** or **source mod**.
- **Show current Head/Hair:** click the button to filter the list to the hair or head you currently have equipped and read off its thumbnail number, so you can find the active style in the grid. Clear the filter with **Refresh**, by typing, by toggling a source-mod filter, with **Show all mods**, or by reopening the panel.
- **Apply a result:** click it — the hair/head changes immediately.
- **Walk through matches:** **Previous / Next** buttons; the status line shows the match number and the tile number to look for in the grid.

## Troubleshooting

### No labels, no panel — nothing changed

- Confirm **Script Extender is loaded** (its console window appears when BG3 runs). Without it, CCNS does nothing.
- Confirm **CCNS is in your active load order**, not the Overrides pane (see step 3 above). This is the single most common cause.
- Check the Script Extender console for a `[CCNS] CCNS v11.14 loaded …` line at startup. If it's absent, the script isn't loading — re-check load order.

### The panel opens, but the thumbnails have no numbers

- Click back and forth between the **Hair and Head tabs** 1–2 times. BG3 only repaints the tile labels when a tab is rebuilt, so the round trip is what makes the numbers show. Once they appear they stay for the rest of the session.

### `Ctrl + Shift + H` does nothing

- The panel only opens while you're on the **Head or Hair** screen — the hotkey is intentionally a no-op elsewhere. Make sure you're on the hair/head picker.
- If it still won't open there, another mod may be binding `Ctrl + Shift + H`.

### Labels show, but the panel lists everything as "Vanilla"

- The Script Extender script isn't running, or hasn't run yet. Make sure CCNS is **active in load order** (step 3) and launch the game at least once after enabling it.

### Labels don't appear, or appear wrong, after installing another UI mod

- Another mod may be replacing `CCLib_k.xaml` or `CCLib_c.xaml`. Only one such override can win, decided by load order. Most notably, **Customizer's Compendium (mod 10)** conflicts; use the **Patch 7 Ready** version (mod **12111**) instead. Put CCNS after other UI mods in your load order if you want it to win.

### Controller: labels don't show

- The game loads the controller UI only while you're actually using a gamepad. Switch to your controller and reopen the hair/head grid. (Note: the search panel itself is keyboard/mouse only, and the brighter selection ring is keyboard-layout only.)

## Uninstalling

1. Delete `CCNS_HairHeadSearch.pak` from your BG3 Mods folder (`%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods`), or remove it in your mod manager.
2. Launch BG3 — the hair/head pickers return to their original look on next launch.

All of CCNS's changes are runtime-only. Uninstalling makes **no permanent change** to your save or your game files.
