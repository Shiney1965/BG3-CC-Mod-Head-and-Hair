# CCNS — CC Hair & Head Search

## New in 1.1.0 — Show current Head/Hair

**The search panel now has a "Show current Head/Hair" button that filters the list to the option you currently have equipped — the current hair on the Hair screen, the current head on the Head screen — and shows its exact thumbnail number, so you can find the active style in the grid without hunting for the gold-outlined tile.** Clear it again with Refresh, by typing in the search box, by toggling a source-mod filter, with "Show all mods," or by reopening the panel.

---

**Name labels, mod-of-origin info, tile numbers, and an in-game search panel for the character-creation hair and head pickers.**

If you run a lot of hair and head mods, you have probably scrolled through hundreds of near-identical thumbnails with no idea which mod a style came from or where it was in the grid. CCNS puts a readable **name** and **source mod** under every hair/head tile, numbers them all in grid order, and adds a **search box** that filters by name or by mod and walks you through the matches.

---

## How to use — please read

**TO USE THE SEARCH PANEL, PRESS Ctrl+Shift+H WHILE ON THE HEAD OR HAIR SCREEN. THEN CLICK BACK AND FORTH BETWEEN THE HAIR AND HEAD TABS UNTIL THE NUMBERS APPEAR ON THE THUMBNAILS IN BOTH — USUALLY 1–2 ROUND TRIPS.**

- The numbers should be **permanently assigned**; if they are ever removed during the game, just repeat this round trip when you re-enter the CC panels.
- **Type** in the box to filter by hair/head name or source mod.
- **Show current Head/Hair** — click this button to filter the list to the hair or head you currently have equipped and read off its thumbnail number. Clear it with Refresh, typing, a source-mod filter, "Show all mods," or by reopening the panel.
- **Click** a result to apply it; or use **Previous / Next** to step through matches — the status line shows the match number and the tile number to look for.
- You can **close and reopen** the panel any time with Ctrl+Shift+H while on the Head or Hair screen. The hotkey does nothing on other screens (by design).

*Why the tab round-trip?* BG3 recycles the thumbnail tiles and only repaints their labels when a tab is rebuilt, so a quick Head↔Hair switch is what makes the numbers show up.

---

## Features

- **Name label on every hair and head tile** — single line, trimmed if long; full name on hover.
- **Mod-of-origin line** under the name (e.g. Lydia's Heads, HairUnlocked, Poesielibre's Heads). Base-game options read as "Vanilla."
- **Tile numbers** on all hair/head tiles, in the order they appear in the grid, so search results map to a spot in the grid.
- **In-game search panel** (Ctrl+Shift+H) — filter by name or source mod, click a result to apply it instantly, or step through matches with Previous / Next.
- **Show current Head/Hair** *(new in 1.1.0)* — filter the list to the option you currently have equipped and read its thumbnail number, so you can find the active style in the grid without scrolling for the gold-outlined tile.
- **Brighter selection ring** on the active tile (keyboard/mouse layout).
- **Keyboard and controller** — labels and numbers render in both.
- **Zero gameplay impact** — cosmetic / informational only; no background polling; nothing is written to your save.

---

## Requirements

- Baldur's Gate 3, Patch 8 or later.
- **BG3 Script Extender** (version 29+). Required — drives the labels, numbering, and search panel.
- A mod manager (e.g. BG3 Mod Manager) — strongly recommended, because CCNS must be **active in your load order** for its script to run.

**Recommended (not required):** BG3 ImprovedUI — the Patch 8 fork (mod **16649**). CCNS runs without it, but they're tested together.

---

## Controller

- The name/mod labels and the thumbnail numbers **render on the controller layout**.
- The **search panel is keyboard/mouse only** (it's a mouse-driven overlay); numbering is baked when you open the panel, so it's keyboard/mouse-driven too. The **Show current Head/Hair** button is part of that panel, so it is keyboard/mouse only as well.
- The **brighter selection ring is keyboard-layout only** — controllers get the game's normal highlight.

---

## Compatibility

- **Appearance Edit Enhanced (AEE)** and the **Magic Mirror** — compatible; everything works in the mid-game appearance editor too (open the panel with Ctrl+Shift+H on the Head/Hair screen).
- **BG3 ImprovedUI** — compatible and recommended.
- **Customizer's Compendium (mod 10) — incompatible** (it fully replaces CCLib_k.xaml). Use the Patch 7 Ready version (mod **12111**) instead.
- Any mod that fully replaces CCLib_k.xaml or CCLib_c.xaml will conflict — load order decides which wins.

---

## Known limitations

- Tile numbers appear after a **Head↔Hair tab round-trip** (1–2) — BG3 recycles tiles and only repaints labels on a tab rebuild. One-time step per session.
- The panel is **opened by hotkey**; it does not auto-open (an always-on check to auto-open added a constant background cost, so it was removed).
- Matches are shown by **number**, not highlighted in the grid — the game's hair/head collections are read-only at runtime, so the mod can't glow, hide, or scroll to tiles. Tile numbers, Next/Previous, and Show current Head/Hair are the workaround.
- An option the game doesn't attribute to a mod source shows as "Vanilla."
- CCNS must be **active in your load order** (not just the Overrides pane) for the script-driven features to appear.

---

## Credits

- **Author:** Serpentine (SerpentineShel)
- **BG3 Script Extender:** Norbyte
- **BG3 ImprovedUI** and its Patch 8 fork maintainers
- **Larian Studios** — the base character-creation UI this mod extends
- Thanks to the BG3 modding community for testing and feedback.

## AI use disclosure

CCNS was developed with substantial assistance from an AI coding assistant (Claude, by Anthropic) for code, research, and documentation. It contains **no AI-generated art, images, audio, or other media** — only code and text. All design decisions, testing, and the final release were done by the author.

## Source code

CCNS is open source. Full source (UI files, Script Extender Lua, build scripts, docs) is on GitHub:
<https://github.com/Shiney1965/BG3-CC-Mod-Head-and-Hair>

## License

MIT (original CCNS code/content). Includes a modified copy of Larian's character-creation UI files; see LICENSE-THIRD-PARTY.md in the download.
