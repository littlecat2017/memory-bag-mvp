# R4 Test Report

Last updated: 2026-06-03

## Scope

R4 verifies the graybox travel and automatic battle loop. It does not implement final combat rules, HP math, battle animation, reward inventory, final character art, enemy art, or final UI skinning.

## Automated Checks

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Result: passed.

Checked:

- `F0003` enters battle mode from the original source script.
- Battle state starts active and unresolved.
- The hero placeholder stays left of the enemy placeholder.
- Hero and enemy placeholders stay above the operation tray.
- The battle status box stays inside the stage and to the right of the enemy placeholder.
- Calling `advance_battle()` once resolves the battle and shows victory state.
- Calling `advance_battle()` again advances to source-script event `F0004`.
- R0-R3 loading, layout, playback, choice, and backpack replacement checks still pass.

Known engine warning:

- Godot still reports a non-equal anchor size warning during setup. It remains a cleanup item and does not currently fail verification.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

New R4 files:

- `reboot/temp/screenshots/03_battle_graybox.png`
- `reboot/temp/screenshots/03b_battle_resolved_graybox.png`

## Visual Observations

- Active battle screenshot: hero, enemy, floor baseline, operation tray, discard zone, backpack grid, and found-memory zone are visible.
- Resolved battle screenshot: battle status changes to the victory state.
- The status box is readable and positioned to the right of the enemy placeholder without covering hero, enemy, or the backpack tray.
- This is still graybox only. The status box intentionally has simple flat fill and no final art frame.

## Not Verified Yet

- Real battle mechanics, HP, damage, enemy turns, rewards, or failure states.
- Final combat animation and character/enemy art.
- Reward persistence into inventory.
- Manual full playthrough to an ending.
