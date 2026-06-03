# R3 Test Report

Last updated: 2026-06-03

## Scope

R3 verifies the first playable memory-backpack loop. It does not implement final drag/drop, final UI art, item icons, or unlocked-slot progression beyond the initial four slots.

## Automated Checks

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Result: passed.

Checked:

- The standard opening still grants exactly four initial memories.
- The visible backpack keeps the 7x4 grid while enforcing only four unlocked slots.
- Choosing a new forest memory while the four unlocked slots are full opens `memory_replace` mode.
- The pending new memory is tracked and displayed.
- Replacing slot 1 discards the old memory, inserts the new memory, preserves four owned memories, and resumes the source-script branch.
- Discard state is recorded for later condition checks.
- R1/R2 layout and playback checks still pass.

Known engine warning:

- Godot still reports a non-equal anchor size warning during setup. It remains a cleanup item.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

New R3 files:

- `reboot/temp/screenshots/08_memory_replace_graybox.png`
- `reboot/temp/screenshots/09_memory_replace_result_graybox.png`

## Visual Observations

- Memory replacement screenshot: pending memory, current backpack, and discard pile are visible at the same time.
- The first four unlocked slots show memory names; locked slots remain visible and disabled-looking.
- Replacement result screenshot: after replacing slot 1, the script resumes to the original branch text.
- The replacement instruction panel is readable and no longer covers the backpack operation tray.

## Known Visual Issues

- The replacement instruction panel still sits inside the stage area and partially covers the character placeholder. This is acceptable for R3 graybox but should be resolved before final UI skinning.
- Memory cell labels are abbreviated to fit the current graybox cells. Final UI should use icons and tooltips/details instead of long text inside tiny cells.

## Not Verified Yet

- Drag/drop replacement.
- Unlocking additional backpack slots.
- Item icons and final memory-card art.
- Multiple pending memories in a single replacement sequence beyond the first deterministic case.
