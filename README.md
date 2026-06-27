# CCNS — CC Hair & Head Search

Adds **name labels, mod-of-origin info, tile numbers, and an in-game search panel** to Baldur's Gate 3's character-creation hair and head pickers. When you open the hair or head grid — in New Game character creation, the Magic Mirror, or a mid-game appearance editor — each tile now shows the option's name and which mod it came from, and a searchable panel lets you jump straight to the one you want.

```
  [hair tile]            [hair tile]            [hair tile]
  #12 Wavy Bob           #13 Long Braids        #14 Shaved Sides
  Lydia's Heads          Vanilla                HairUnlocked
```

If you run a lot of hair and head mods, you have probably scrolled through hundreds of near-identical thumbnails with no idea which mod a style came from or where in the grid it was. CCNS puts a readable name and source-mod under every tile, numbers the modded ones, and gives you a search box that filters by name **or** by source mod and walks you through the matches.

## Features

- **Name label on every hair and head tile** — single line, trimmed with an ellipsis if long; the full name is always available on hover via the tile's normal tooltip.
- **Mod-of-origin line** under the name, resolved per tile from the game's appearance-visual data (e.g. *Lydia's Heads*, *HairUnlocked*, *Poesielibre's Heads*). Base-game options read as *Vanilla*.
- **Grid tile numbers** — each modded hair/head tile is numbered (`#1`, `#2`, …) so you can match a search result to its place in the grid.
- **In-game search panel** — a lightweight overlay (opened with a hotkey) that lists every hair/head with its name, source mod, and tile number. Type to filter by name or by mod; click a result to apply it instantly; or step through matches with **Previous / Next**.
- **Brighter selection ring** on the currently-selected tile, so it's easier to see which option is active.
- **Keyboard and controller** — labels and numbers render in both the keyboard and the controller character-creation UI.
- **Zero gameplay impact.** Cosmetic / informational only. All changes are applied at runtime each launch; nothing is written to your save.

## Requirements

- **Baldur's Gate 3**, Patch 8 or later.
- **BG3 Script Extender (BG3SE)**, version 29 or later. Required — the labels, numbering, and search panel are all driven by Script Extender Lua. Get it from <https://bg3.community/>.
- **BG3 ImprovedUI (ImpUI)** — required. CCNS is built and tested against the ImprovedUI Patch 8 fork (NexusMods mod **16649**, *ImpUI_P8_Fork*). Install and enable it before CCNS.
- **A mod manager** such as BG3 Mod Manager (BG3MM) — strongly recommended, because CCNS must be **active in your load order** (not just sitting in the Overrides pane) for its Script Extender script to run. See `INSTALL.md`.

No Python, no sidecar, no external tools. Everything runs in-game.

## How it works (brief technical overview)

CCNS ships an override of the base-game character-creation UI library (`CCLib_k.xaml` for keyboard, `CCLib_c.xaml` for controller). The override adds a small name-label element to the shared hair/head tile template — scoped so it appears only on the hair and head grids, not on every appearance picker.

At launch, a Script Extender Lua client script builds a map from each character-creation appearance visual to the mod that supplied it (using the engine's static-data sources), then bakes the option's name, tile number, and source mod into the text the tile displays. The same data drives the search panel, which reads the live hair/head collections and applies your selection back to the game.

Nothing is written to your save. All text and UI changes are applied at runtime on each launch, and removing the mod reverts everything on the next launch.

## Controls

- **Open / close the search panel:** `Ctrl + Shift + H` (works on any character-creation screen, including the Magic Mirror and mid-game appearance editors). The panel also opens automatically when you enter New Game character creation.
- **Search:** type in the panel's text box to filter by hair/head **name** or by **source mod**.
- **Apply:** click a result to select that hair/head immediately.
- **Step through matches:** use the **Previous / Next** buttons; the status line shows which match you're on and its tile number.
- **Console fallback** (if the hotkey is ever unavailable): open the Script Extender console, switch to the client context, and run `Mods.CCNS_HairHeadSearch.CCNS_Search()`.

## Compatibility

- **Appearance Edit Enhanced (AEE)** and the **Magic Mirror** — fully compatible. Labels, numbers, and the search panel work in the mid-game appearance editor exactly as they do in New Game character creation.
- **Other UI / tooltip mods** — CCNS only modifies the hair/head tile template and runs its own Script Extender script; it does not touch tooltips or other panels.
- **Customizer's Compendium (mod 10)** — **incompatible.** That mod ships a full-file replacement of `CCLib_k.xaml`, which conflicts with CCNS's override (whichever loads last wins, and you lose the other's changes). If you want Customizer's-Compendium-style options, use the **Patch 7 Ready** version on NexusMods (mod **12111**) instead, which does not replace the UI library.
- **Any mod that fully replaces `CCLib_k.xaml` or `CCLib_c.xaml`** will conflict for the same reason. Load order decides which one wins.

## Known limitations

- **Matches are shown by number, not highlighted in the grid.** The game's hair/head tile collections are read-only at runtime, so CCNS cannot draw a glow or marker on matching tiles or hide non-matches. Instead, each modded tile is numbered and the search panel's **Next / Previous** navigation tells you which numbered tile to look at. This is a hard engine limitation, not a planned feature.
- **Only modded tiles are numbered.** Base-game (vanilla) hair/head options are intentionally left unnumbered to keep the grid clean and avoid touching base-game text.
- **Some options may read as *Vanilla*.** Mod-of-origin is resolved from the engine's appearance-visual source data. An option that the game does not attribute to a specific mod source will show as *Vanilla*.
- **The mod must be active in your load order** for any of this to appear. As a base-game-file override it can otherwise sit in your manager's Overrides pane, where its Script Extender script does not run. See `INSTALL.md`.

## FAQ

**Q: What is BG3 Script Extender, and do I really need it?**
A: Yes. It's a required dependency that lets mods run Lua code. The labels, numbering, and search panel are all Script Extender features — without it, CCNS does nothing. Install it from <https://bg3.community/>.

**Q: Do I need ImprovedUI?**
A: Yes. CCNS is built and tested against the ImprovedUI Patch 8 fork (NexusMods 16649). Install and enable it before CCNS.

**Q: The search panel won't open with the hotkey. What now?**
A: Open the Script Extender console, switch to the client context, and run `Mods.CCNS_HairHeadSearch.CCNS_Search()`. If that works but the hotkey doesn't, check that no other mod is binding `Ctrl + Shift + H`.

**Q: I see labels but the panel says everything is "Vanilla."**
A: Make sure the mod is active in your load order (not just in the Overrides pane) so its Script Extender script runs, and that you have launched at least once after enabling it.

**Q: Does it work with a controller?**
A: Yes — the labels and numbers render in the controller UI as well as keyboard. (The game loads the controller UI only when you're using a gamepad.)

**Q: Will this affect my save or my game's performance?**
A: No. All work happens at launch; tiles render normally afterward. Nothing is written to your save, and uninstalling reverts everything on the next launch.

**Q: What does "CCNS" stand for?**
A: "CC Name & Search" — character-creation name labels plus search.

## Credits

- **Author:** Serpentine (NexusMods: SerpentineShel)
- **BG3 Script Extender:** [Norbyte](https://github.com/Norbyte/bg3se) — none of the runtime features would be possible without it.
- **BG3 ImprovedUI** and its Patch 8 fork maintainers — the UI framework CCNS builds on.
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
