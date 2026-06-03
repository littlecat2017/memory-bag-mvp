# Visual Layout Spec

Last updated: 2026-06-03

This file records the runtime layout contract for the MVP screen. The goal is to keep Godot implementation aligned with the approved concept image instead of rebuilding UI from scattered anchors.

## Source Of Truth

- Machine-readable layout: `data/visual_layout.json`
- Design canvas: `1280x720`
- Concept reference: `docs/art_direction/final/final_memory_backpack_art_direction.png`
- Runtime helper functions: `scripts/runtime/main.gd`
- Contract tests:
  - `scripts/debug/verify_visual_contract.gd`
  - `scripts/debug/verify_quick_bag_interaction.gd`
  - `scripts/debug/verify_visual_layout_bounds.gd`

## Backpack Contract

- The visible backpack grid is always `7 columns x 4 rows`, for `28` total cells.
- MVP starting capacity is `4`, but this is an unlock count, not the total UI size.
- The first 4 cells are unlocked at MVP start.
- Cells 5 through 28 remain visible and use the gray locked-cell texture.
- Locked cells reject drag/drop operations.
- Future upgrades should unlock additional cells inside the same 7x4 grid. Do not rebuild the backpack as a 2x2 or 4-slot UI.

## Lower Operation Tray

The lower half has three separate zones:

- Left: trash/discard pile.
- Center: 7x4 memory backpack grid.
- Right: newly found memory.

The tray image is only a skin/frame. The real interactive cells are placed by Godot from `visual_layout.sections.inventory_board`.

## Dialogue Contract

- Dialogue mode shows the Galgame dialogue box and hides the backpack tray.
- Backpack mode shows the lower operation tray and hides the dialogue box.
- These two lower UI modes must not overlap.

## Battle And Travel Contract

- Travel uses the upper stage with the chibi hero centered and standing on the scene floor.
- Battle uses the upper stage with the hero on the left and enemy on the right.
- Hero and enemy feet must stay above the lower operation tray.
- Chibi units, battle effects, and inventory UI are separate layers; do not bake them into one concept image.

## Asset Rules

- `ui_quick_bag_tray` is the tray/frame art.
- `ui_inventory_cell_unlocked` and `ui_inventory_cell_locked` are per-cell textures generated locally by Godot, so they do not count against the daily image2 budget.
- No secrets, API keys, or signed image URLs may be written into layout, docs, logs, or tests.
