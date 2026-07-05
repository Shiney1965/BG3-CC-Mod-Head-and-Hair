# CCNS — CC Hair & Head Search

Adds **name labels, mod-of-origin info, tile numbers, and an in-game search panel** to Baldur's Gate 3's character-creation hair and head pickers. On the hair or head grid — in New Game character creation, the Magic Mirror, or a mid-game appearance editor — each tile shows the option's name and which mod it came from, and a searchable panel (opened with a hotkey) lets you jump straight to the one you want.

```
  [hair tile]            [hair tile]            [hair tile]
  #12 Wavy Bob           #13 Long Braids        #14 Shaved Sides
  Lydia's Heads          Vanilla                HairUnlocked
```

If you run a lot of hair and head mods, you have probably scrolled through hundreds of near-identical thumbnails with no idea which mod a style came from or where in the grid it was. CCNS puts a readable name and source-mod under every tile, numbers them all in grid order, and gives you a search box that filters by name **or** by source mod and walks you through the matches.

## ➤ How to use — please read this

**TO USE THE SEARCH PANEL, PRESS `CTRL+SHIFT+H` WHILE YOU ARE ON THE HEAD OR HAIR SCREEN. THEN CLICK BACK AND FORTH BETWEEN THE HAIR AND HEAD TABS UNTIL THE NUMBERS APPEAR ON THE THUMBNAILS IN BOTH — THIS USUALLY TAKES ONLY 1–2 ROUND TRIPS.**

Once the numbers appear:

- The numbers should be **permanently assigned**, but if they are ever removed during the game, just repeat this procedure (the Head↔Hair round trip) when you re-enter the CC panels to reassign them.
- Type in the search box to filter hairs/heads by **name**; use the source-mod list to filter by the **mod** a style came from.
- **Click a result to apply it**, or use **Previous / Next match** to step through matches on your character.
- Each result shows its thumbnail number (e.g. `#12`) so you can find it in the grid.
- You can **close and reopen** the search panel any time with `CTRL+SHIFT+H` while on the Head or Hair screen. The hotkey does nothing on other screens (by design).

### Why the tab round-trip is needed

Baldur's Gate 3 reuses ("recycles") the thumbnail tiles as you scroll, and it only redraws a tile's label when the tab is rebuilt. CCNS writes the numbers into the tile labels, but the already-drawn tiles don't repaint until the game rebuilds them — which is what a Head→Hair→Head tab switch does. That's why a quick round trip between the two tabs makes all the numbers show up.

## Features

- **Name label on every hair and head tile** — single line, trimmed with an ellipsis if long; the full name is always available on hover via the tile's normal tooltip.
- **Mod-of-origin line** under the name, resolved per tile from the game's appearance-visual data (e.g. *Lydia's Heads*, *HairUnlocked*, *Poesielibre's Heads*). Base-game options read as *Vanilla*.
- **Grid tile numbers** — all head and hair options are numbered (`#1`, `#2`, …) in the order they appear in the CC grid, so you can match a search result to its place in the grid (see the round-trip note above).
- **In-game search panel** — a lightweight overlay opened with `Ctrl+Shift+H` that lists every hair/head with its name, source mod, and tile number. Type to filter by name or by mod; click a result to apply it instantly; or step through matches with **Previous / Next**.
- **Brighter selection ring** on the currently-selected tile (keyboard/mouse layout).
- **Keyboard and controller** — the labels and numbers render in both the keyboard and controller character-creation UI. (The search panel itself is a keyboard/mouse feature — see *Controller* below.)
- **Zero gameplay impact.** Cosmetic / informational only. All changes are applied at runtime each launch; nothing is written to your save.

## Requirements

- **Baldur's Gate 3**, Patch 8 or later.
- **BG3 Script Extender (BG3SE)**, version 29 or later. Required — the labels, numbering, and search panel are all driven by Script Extender Lua. Get it from <https://bg3.community/>.
- **A mod manager** such as BG3 Mod Manager (BG3MM) — strongly recommended, because CCNS must be **active in your load order** (not just sitting in the Overrides pane) for its Script Extender script to run. See `INSTALL.md`.

**Recommended (not required):** **BG3 ImprovedUI** — the Patch 8 fork (NexusMods mod **16649**, *ImpUI_P8_Fork*). CCNS runs on its own, but it is built and tested alongside ImprovedUI and they play nicely together.

No Python, no sidecar, no external tools. Everything runs in-game.

## Controls

- **Open / close the search panel:** `Ctrl + Shift + H`, while on the **Head or Hair** screen (New Game character creation, the Magic Mirror, or a mid-game appearance editor). The hotkey is a no-op on other screens. Closing works anywhere.
- **Search:** type in the panel's text box to filter by hair/head **name** or by **source mod**.
- **Apply:** click a result to select that hair/head immediately.
- **Step through matches:** use the **Previous / Next** buttons; the status line shows which match you're on and its tile number.

## Controller

- The name and mod-of-origin **labels — and the thumbnail numbers — render on the controller layout**, the same as on keyboard/mouse.
- The **search panel itself is a keyboard/mouse feature**: it opens with `Ctrl+Shift+H` and is operated with the mouse (it is not navigable with a controller). Because the numbering is baked when you open the panel, numbering is likewise keyboard/mouse-driven.
- The **brighter selection ring is keyboard-layout only** — on the controller layout you'll see the game's normal selection highlight instead.

## How it works (brief technical overview)

CCNS ships an override of the base-game character-creation UI library (`CCLib_k.xaml` for keyboard, `CCLib_c.xaml` for controller). The override adds a small name-label element to the shared hair/head tile template — scoped so it appears only on the hair and head grids, not on every appearance picker.

At launch, a Script Extender Lua client script builds a map from each character-creation appearance visual to the mod that supplied it (using the engine's static-data sources), then bakes the option's name, tile number, and source mod into the text the tile displays. The same data drives the search panel, which reads the live hair/head collections and applies your selection back to the game. The panel is summoned only by `Ctrl+Shift+H`, and the keypress checks that you're on the Hair/Head picker before opening — there is no always-on background polling.

Nothing is written to your save. All text and UI changes are applied at runtime on each launch, and removing the mod reverts everything on the next launch.

## Compatibility

- **Appearance Edit Enhanced (AEE)** and the **Magic Mirror** — compatible. Labels, numbers, and the search panel work in the mid-game appearance editor exactly as they do in New Game character creation (open the panel the same way, with `Ctrl+Shift+H` on the Head/Hair screen).
- **BG3 ImprovedUI** — compatible and recommended; CCNS is tested alongside it.
- **Other UI / tooltip mods** — CCNS only modifies the hair/head tile template and runs its own Script Extender script; it does not touch tooltips or other panels.
- **Customizer's Compendium (mod 10)** — **incompatible.** That mod ships a full-file replacement of `CCLib_k.xaml`, which conflicts with CCNS's override (whichever loads last wins, and you lose the other's changes). If you want Customizer's-Compendium-style options, use the **Patch 7 Ready** version on NexusMods (mod **12111**) instead, which does not replace the UI library.
- **Any mod that fully replaces `CCLib_k.xaml` or `CCLib_c.xaml`** will conflict for the same reason. Load order decides which one wins.

## Known limitations

- **The tile numbers appear after a Head↔Hair tab round-trip** (usually 1–2), because BG3 recycles the thumbnail tiles and only repaints their labels when a tab is rebuilt. This is a one-time step per character-creation session — see *How to use* above.
- **The search panel is opened by hotkey; it does not pop open automatically.** This is deliberate — an always-on check to auto-open it added a constant background cost and log spam, so CCNS uses the on-demand `Ctrl+Shift+H` hotkey instead.
- **Matches are shown by number, not highlighted in the grid.** The game's hair/head tile collections are read-only at runtime, so CCNS cannot draw a glow on matching tiles, hide non-matches, or scroll the grid to a match. Instead, each tile is numbered and the search panel's **Next / Previous** navigation tells you which numbered tile to look at. This is a hard engine limitation.
- **Some options may read as *Vanilla*.** Mod-of-origin is resolved from the engine's appearance-visual source data. An option the game does not attribute to a specific mod source will show as *Vanilla*.
- **The mod must be active in your load order** for any of this to appear. As a base-game-file override it can otherwise sit in your manager's Overrides pane, where its Script Extender script does not run. See `INSTALL.md`.

## FAQ

**Q: What is BG3 Script Extender, and do I really need it?**
A: Yes. It's a required dependency that lets mods run Lua code. The labels, numbering, and search panel are all Script Extender features — without it, CCNS does nothing. Install it from <https://bg3.community/>.

**Q: Do I need ImprovedUI?**
A: No — it's recommended, not required. CCNS runs on its own. ImprovedUI is a tested, compatible companion; install it if you like, but CCNS does not depend on it.

**Q: I pressed `Ctrl+Shift+H` and nothing happened.**
A: The panel only opens while you're on the **Head or Hair** screen — the hotkey is intentionally a no-op elsewhere. Make sure you're on the hair/head picker, and that no other mod is binding `Ctrl+Shift+H`.

**Q: The panel opened but the thumbnails have no numbers.**
A: Click back and forth between the Hair and Head tabs 1–2 times — BG3 only repaints the tile labels when a tab is rebuilt. The numbers will then appear and stay.

**Q: I see labels but the panel says everything is "Vanilla."**
A: Make sure the mod is active in your load order (not just in the Overrides pane) so its Script Extender script runs, and that you have launched at least once after enabling it.

**Q: Does it work with a controller?**
A: The labels and numbers render in the controller UI. The search panel itself is keyboard/mouse only (it's a mouse-driven overlay), and the brighter selection ring is keyboard-layout only. See *Controller* above.

**Q: Will this affect my save or my game's performance?**
A: No. All work happens at launch and on-demand when you open the panel; there's no background polling. Nothing is written to your save, and uninstalling reverts everything on the next launch.

**Q: What does "CCNS" stand for?**
A: "CC Name & Search" — character-creation name labels plus search.

## Credits

- **Author:** Serpentine (NexusMods: SerpentineShel)
- **BG3 Script Extender:** [Norbyte](https://github.com/Norbyte/bg3se) — none of the runtime features would be possible without it.
- **BG3 ImprovedUI** and its Patch 8 fork maintainers — the UI framework CCNS is tested alongside.
- **Larian Studios** — the base character-creation UI that CCNS extends.
- **Testing and feedback:** the BG3 modding community.

## AI use disclosure

CCNS was developed with substantial assistance from an AI coding assistant (Claude, by Anthropic), used for code authoring (Script Extender Lua and XAML edits), research, and this documentation. The mod contains **no AI-generated art, images, audio, or other media** — only code and text. All design decisions, in-game testing, and the final release were done by the author.

## Source code

CCNS is open source. The full source — UI files, Script Extender Lua, build scripts, and these documents — lives on GitHub:

<https://github.com/Shiney1965/BG3-CC-Mod-Head-and-Hair>

## License

MIT. See `LICENSE`. The mod includes a modified copy of Larian's character-creation UI files; see `LICENSE-THIRD-PARTY.md`.

## Reporting issues

Drop a comment on the NexusMods listing, or open an issue on the [GitHub repository](https://github.com/Shiney1965/BG3-CC-Mod-Head-and-Hair). When reporting, please include:

- Your BG3 version and Script Extender version.
- Whether you are on keyboard or controller.
- Your Script Extender console log from the session where the problem happened.
- The other UI / character-creation mods in your load order (especially anything that modifies `CCLib_k.xaml` or `CCLib_c.xaml`).
- Which hair/head option or which screen the problem appears on.
