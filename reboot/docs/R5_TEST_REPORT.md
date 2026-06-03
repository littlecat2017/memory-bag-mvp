# R5 Test Report

Last updated: 2026-06-03

## Scope

R5 verifies MVP end-to-end completion for one deterministic route through the original source script. It remains a graybox MVP: no final art replacement, final combat system, animation, audio, save/load, or packaged build is included in this round.

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
- Final route: `kill_demon`.
- Final selected ending: `hero`.
- Ending event reached: `E0001`.

Checked:

- The runtime loads all memory definitions from the original JSONL source script.
- Late-game automatic `memory_gain` events stop in memory replacement mode when the backpack is full.
- Replacement resumes script playback after the pending memory is inserted.
- The deterministic route reaches the final choice `K0026`.
- The deterministic route preserves `mem_reason_to_depart` and `mem_my_name`.
- Ending selection follows the source-script condition logic and lands on `hero`.
- The ending screen shows the original hero-ending source text plus a final backpack summary.
- R0-R4 layout, playback, battle, and backpack checks still pass.

Known engine warning:

- Godot still reports a non-equal anchor size warning during setup. It remains a cleanup item and does not currently fail verification.

## Screenshots

Command:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

Result: passed.

New R5 file:

- `reboot/temp/screenshots/10_mvp_ending_graybox.png`

## Visual Observations

- The ending screenshot is readable: the left panel shows the hero ending summary, route, selected ending id, and core-memory status.
- The right panel shows final backpack contents, discarded memories, and the warmth score.
- The two ending panels do not overlap each other or the bottom buttons at 1280x720.
- This is still graybox quality. It is not a final art/UI pass.

## Not Verified Yet

- Other endings and route-specific visual states.
- Manual mouse-only playthrough.
- Commercial art quality.
- Final combat rules, animation, VFX, audio, save/load, settings, and packaged release build.
