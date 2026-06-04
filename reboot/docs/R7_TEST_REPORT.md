# R7 Test Report

Last updated: 2026-06-04

## Scope

R7 completes the mouse-first graybox MVP loop. It does not add final art, audio, save/load, final combat rules, or packaged release output.

## Implemented

- Title screen quit button now has a real quit action.
- Backpack grid can open the backpack detail screen by mouse in travel/battle modes.
- Backpack detail screen can return to the previous story mode.
- Ending screen buttons now work:
  - Restart begins a fresh run at `T0001`.
  - Back to title resets runtime state and returns to title mode.
- Existing mouse click, long-hold advance, choice click, and drag replacement behavior remains intact.

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

Observed full-playthrough output:

- 164 source-script events visited.
- 10 battles resolved.
- 4 backpack replacements completed.
- Final selected ending: `hero`.

Screenshot command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

## Not Verified Yet

- Final art direction.
- Controller/touchscreen input.
- Save/load and packaged executable.
- Full route coverage for every ending.
