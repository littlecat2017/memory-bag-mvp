# Memory Backpack Reboot

This is the clean reboot project.

Run from this directory:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path .
```

Verification:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --headless --path . -s 'res://scripts/debug/verify_reboot_shell.gd'
```

Screenshot capture:

```powershell
& '..\temp\godot\extracted\Godot_v4.6.3-stable_win64_console.exe' --path . -s 'res://scripts/debug/capture_reboot_screens.gd'
```

The previous prototype remains in Git history and should not be used as the reboot runtime source.

Current reboot reports:

- `docs/R0_TEST_REPORT.md`
- `docs/R1_TEST_REPORT.md`
- `docs/R2_TEST_REPORT.md`
