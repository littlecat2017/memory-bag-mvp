# R6 Test Report

Last updated: 2026-06-04

## Scope

R6 adds mouse-first MVP interaction. It does not change source story, art, combat rules, or the graybox layout.

## Implemented

- Left-click can advance title, dialogue, travel, battle, and ending modes.
- Holding the left mouse button repeatedly advances eligible modes.
- Existing choice buttons remain mouse-clickable.
- Backpack replacement can be completed by dragging an owned memory from the backpack to the discard zone.
- Dragging shows a floating preview and fades the source cell while dragging.
- Clicking an unlocked backpack slot in replacement mode still works as a fallback.

## Automated Checks

Baseline command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Result: passed.

Full MVP playthrough command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_mvp_playthrough.gd'
```

Result: passed.

Checked:

- Pointer advance starts the script from title.
- Pointer advance progresses dialogue.
- Pointer advance resolves battle and continues after victory.
- Drag replacement starts from an inventory cell, shows a preview, drops on discard zone, and resumes the selected source-script branch.
- Existing keyboard and deterministic full-playthrough checks still pass.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

## Not Verified Yet

- Manual long-hold feel on different machines.
- True drag/drop polish, cursor icons, hover states, and final UI art.
- Touchscreen/mobile input.
