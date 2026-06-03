# R2 Test Report

Last updated: 2026-06-03

## Scope

R2 verifies source-script playback. It does not implement final backpack drag/drop, final battle rules, final art, or animation.

## Automated Checks

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Result: passed.

Checked:

- The full source-script event set loads, including tutorial, prologue, forest, mountain, city, castle, and ending ids.
- Title mode starts on a real title screen.
- `start_script()` begins at `T0001`.
- `advance_script()` can progress through the tutorial/prologue sequence without invented text.
- Playback reaches `P0034`, the initial backpack choice from the source script.
- Choice mode shows source-script text and valid options.
- Choosing the standard opening option jumps to `P0035A`.
- The standard opening option applies its source-script effects and grants four initial memories.
- Existing R1 layout assertions still pass.

Known engine warning:

- Godot still reports a non-equal anchor size warning during setup. It does not currently fail verification, but it remains a cleanup item.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

New R2 files:

- `reboot/temp/screenshots/06_script_choice_graybox.png`
- `reboot/temp/screenshots/07_script_choice_result_graybox.png`

## Visual Observations

- Script choice screenshot: the source-script prompt is visible in the dialogue panel, and the choice panel sits above/right without covering the prompt.
- Choice buttons fit the current graybox panel for the initial two-option choice.
- Choice result screenshot: the selected branch displays the original `P0035A` text and returns to dialogue mode.

## Not Verified Yet

- Manual playthrough from start to ending.
- Real memory replacement when the backpack is full.
- Drag/drop backpack operation.
- Battle result simulation beyond mode switching.
- Final ending route scoring beyond the first deterministic implementation.
