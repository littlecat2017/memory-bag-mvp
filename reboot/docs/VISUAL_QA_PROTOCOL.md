# Visual QA Protocol

Last updated: 2026-06-03

This protocol exists because a passing runtime test is not the same as a visually acceptable game screen.

## QA Layers

### 1. Code Validation

Checks whether data loads, scripts parse, and scenes instantiate.

This can answer:

- Does the game run?
- Are required nodes present?
- Did data validation fail?

This cannot answer:

- Does the UI look good?
- Is the composition commercial-quality?
- Are image edges clean enough?

### 2. Layout Validation

Checks measurable screen rules.

Required checks:

- All important controls fit inside their declared rectangles.
- Dialogue and backpack modes do not overlap.
- Hero and enemy stay above the operation tray.
- Inventory grid cell count, size, and locked state are correct.
- Text containers do not overflow their boxes.

### 3. Pixel Validation

Checks image-level defects.

Required checks before accepting generated character or enemy art:

- Transparent-background PNG exists.
- Alpha border is clean.
- No green-screen spill on semi-transparent edges.
- No large white halo around cutouts.
- Image dimensions match its asset contract.

Green-screen art is not accepted as final art unless it passes these pixel checks and a screenshot review.

### 4. Screenshot Review

Every visual milestone must export screenshots to `reboot/temp/screenshots/`.

The report must say:

- Which screenshot files were produced.
- Which measurable checks passed.
- Which parts are still subjective and need human review.
- Any visible concerns noticed by the assistant.

Do not write "visual is fine" without attaching or referencing screenshots.

### 5. Human Aesthetic Approval

The user is the final judge for:

- Overall beauty.
- Art direction fit.
- AI taste or synthetic look.
- Whether the screen feels like a commercial game.

## Rejection Rules

Reject and rework a screen if any of these happen:

- UI elements overlap in a way not listed as allowed.
- A character appears to float when the screen requires floor contact.
- Inventory, dialogue, or battle panels hide each other.
- Generated cutouts show visible green, white, or dirty borders.
- Concept art is baked directly into gameplay UI instead of being decomposed into layers.
- The screenshot contradicts the written layout contract.

## Reporting Template

For every visual test report:

1. Screenshots:
   - `path/to/screenshot.png`
2. Automated checks:
   - Passed/failed list.
3. Visual observations:
   - Concrete issues only.
4. Human review needed:
   - Specific questions, not generic "please check".
