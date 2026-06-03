# R0 Test Report

Last updated: 2026-06-03

## Scope

R0 only verifies the clean reboot shell. It does not claim final art quality.

## Automated Checks

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Result: passed.

Checked:

- Original JSONL source script loads.
- At least 80 MVP tutorial/prologue/forest events are available.
- Exactly 8 MVP memories are extracted from the original source script.
- Dialogue mode shows dialogue panel and hides operation tray.
- Travel/memory mode shows operation tray and hides dialogue panel.
- Battle mode shows hero left, enemy right, and both above the tray.
- Inventory shows a 7x4 grid with 28 cells.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

Generated files:

- `reboot/temp/screenshots/01_dialogue_graybox.png`
- `reboot/temp/screenshots/02_travel_graybox.png`
- `reboot/temp/screenshots/03_battle_graybox.png`

## Visual Observations

- Dialogue screenshot: no backpack/dialogue overlap.
- Travel screenshot: hero placeholder is centered above floor line; lower tray shows trash, 7x4 inventory, and new memory zones.
- Battle screenshot: hero placeholder is left of enemy placeholder; both stand above the same floor line; lower tray is separate.
- One visible issue was found and fixed during R0: stage label text originally crossed the hero/enemy placeholders. It is now pinned to the upper-left of the stage.

## Not Verified Yet

- Final UI beauty.
- Commercial-quality art direction.
- Generated character transparency.
- Animation quality.
- Pixel-level alpha edge cleanliness.

These belong to later milestones and require screenshot-based human review.
