# R1 Test Report

Last updated: 2026-06-03

## Scope

R1 verifies visual-contract graybox screens only. It does not claim final art quality, final UI skin quality, animation quality, or commercial presentation quality.

## Automated Checks

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Result: passed.

Checked:

- Original JSONL source script loads.
- Exactly 8 MVP memories are extracted from the original source script.
- Title mode shows the title layer and hides story operation UI.
- Dialogue mode shows dialogue panel and hides operation tray.
- Travel mode shows operation tray and keeps hero above the tray.
- Battle mode shows hero left, enemy right, status inside the stage, and both characters above the tray.
- The main operation inventory shows a full 7x4 grid with 28 visible cells.
- Backpack detail mode separates memory list, memory detail, and the 7x4 inventory board.
- Backpack detail inventory stays visually separated from the return button.
- Ending mode separates summary and final backpack panels.

Known engine warning:

- Godot reports a non-equal anchor size warning during setup. The verification still passes. This should be cleaned before the UI is promoted beyond graybox.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

Generated files:

- `reboot/temp/screenshots/00_title_graybox.png`
- `reboot/temp/screenshots/01_dialogue_graybox.png`
- `reboot/temp/screenshots/02_travel_graybox.png`
- `reboot/temp/screenshots/03_battle_graybox.png`
- `reboot/temp/screenshots/04_bag_detail_graybox.png`
- `reboot/temp/screenshots/05_ending_graybox.png`

## Visual Observations

- Title screenshot: title, buttons, concept preview, and note panel have clear separation. The concept image is reference-only.
- Dialogue screenshot: dialogue panel is isolated from backpack UI. No operation tray appears during dialogue.
- Travel screenshot: hero placeholder is centered above the floor baseline; lower operation area shows trash, 7x4 backpack, and new-memory zone without overlap.
- Battle screenshot: hero and enemy placeholders are on the same floor baseline; status panel now stays inside the stage instead of hanging off the right edge.
- Backpack detail screenshot: memory list, memory detail, and the 7x4 grid are visually separated. The grid no longer sits directly under the return button.
- Ending screenshot: summary and final backpack panels are separated; restart and title buttons sit below the panels.

## Issues Fixed During R1

- Right-side backpack-detail grid was too close to the return button. The layout contract now moves the board down and sizes its cells from the declared board rectangle.
- Runtime screenshots showed the concept reference overlay crossing the travel and battle stage area. Runtime story screens now hide the reference image; the title screen still shows the concept preview.
- Battle status panel appeared to hang off the stage edge. The contract now keeps it inside the stage, and verification asserts that rule.

## Not Verified Yet

- Final art direction.
- Final UI skin.
- Generated asset alpha cleanliness.
- Character, enemy, item, or effect assets.
- Real drag/drop backpack behavior.
- Script playback beyond event loading and selected event jumps.
