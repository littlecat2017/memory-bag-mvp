# Memory Backpack Reboot Plan

Last updated: 2026-06-03

This reboot intentionally stops building on the previous runtime implementation. The old project remains in Git history only. New development happens under `reboot/`.

## What We Keep

- Source story/script only: `reboot/data/source_script.jsonl`
- One approved concept reference only: `reboot/assets/reference/concept_memory_backpack.png`
- Godot engine choice.
- The core premise: memory backpack as the main player operation.

## What We Do Not Keep

- Previous Godot runtime scripts.
- Previous scenes.
- Previous generated character, enemy, UI, effect, and background assets.
- Previous green-screen cutout workflow.
- Previous "screenshot passed, therefore visual passed" workflow.

## Reboot Rules

1. Build graybox first. Every screen must be correct with placeholder rectangles before art is added.
2. Every screen gets a visual contract before implementation.
3. The game uses a fixed 1280x720 design canvas for MVP validation.
4. Assets are layered: background, character, enemy, UI frame, inventory cells, item icons, and effects are separate.
5. No full-screen concept image is used as the actual UI.
6. No green-screen cutout is accepted as final character art.
7. Visual QA reports must include screenshots or measurable checks. Do not claim commercial-quality visual approval from code-only tests.
8. The user is the final judge for aesthetics. Automated tests only verify measurable layout rules.

## MVP Milestones

### R0: Clean Shell

- New Godot project under `reboot/`.
- Load the original source JSONL script.
- Show a clean graybox screen.
- Add screenshot capture and layout assertions.

### R1: Visual Contract Screens

- Title screen.
- Dialogue screen.
- Travel screen.
- Battle screen.
- Backpack interaction screen.
- Ending summary screen.

Each screen must have:

- A 1280x720 layout JSON section.
- A debug screenshot.
- Bounds and overlap tests.
- A human-review checklist.

### R2: Script Playback

- Parse tutorial, prologue, and forest events from the source script.
- Play text strictly from the source script.
- Support choices and simple effects.

### R3: Backpack Prototype

- 7x4 visible grid.
- Initial unlocked cells: 4.
- Locked cells visible and disabled.
- Drag or click-based memory replacement.
- World response text after discarding.

### R4: Travel And Battle Prototype

- Travel stage with hero placeholder centered on a floor baseline.
- Battle stage with hero left and enemy right on the same baseline.
- Automatic battle as a readable system, not final animation.

### R5: Art Replacement

- Replace one asset category at a time.
- Start with background and UI frames.
- Add character/enemy art only when transparent-background assets and alpha checks pass.
- Any failed art asset is rejected before it reaches the scene.

### R5A: MVP End-To-End Completion

- Deterministic title-to-ending playthrough.
- Late-game memory-gain replacement handling.
- Ending route selection from source-script conditions.
- Ending summary screen with final backpack state.

## Definition Of Done For A Screen

- Layout test passes.
- Screenshot exists.
- No element overlap outside allowed regions.
- Text fits in its container.
- All placeholder/art assets stay inside their declared rectangles.
- User or explicit human review confirms the screenshot direction is acceptable.

## Current Status

- R0 complete: clean project shell, source script loading, graybox UI, screenshot capture, and measurable layout tests.
- R1 complete: title, dialogue, travel, battle, backpack detail, and ending graybox screens now have layout-contract coverage and screenshots.
- R2 complete: source-script playback can start, advance through tutorial/prologue, show choices, apply option effects, and jump to source-script targets.
- R3 complete: memory gains respect the initial four-slot capacity, full backpacks open replacement mode, discarded memories are tracked, and branch playback resumes after replacement.
- R4 complete: source-script battle events now enter a readable automatic battle state, resolve on player advance, and continue to the next source-script event.
- R5A complete: automated MVP playthrough reaches source-script hero ending after 164 events, 10 battles, and 4 backpack replacements.

## Current Target

Next: keep MVP graybox stable while either expanding route coverage to other endings or starting controlled art replacement one asset category at a time.
