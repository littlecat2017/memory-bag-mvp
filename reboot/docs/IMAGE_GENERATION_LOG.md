# Image Generation Log

Project rule: generated image usage is capped at 50 images per day. Do not record or expose image API keys here.

## 2026-06-04

Total generated today for this MVP art fill: 8 / 50.

| # | Tool | Prompt Summary | Source Output | Workspace Asset | Status |
|---|---|---|---|---|---|
| 1 | Built-in image generation | 1280x720 gameplay shell in the selected concept style: forest path on top, cloth memory backpack UI on bottom, 7x4 grid, discard pouch, found-memory board, no text. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a2125646cd8819590c3f758b420c499.png` | `reboot/assets/generated/mvp_art/gameplay_shell.png` | Normalized to 1280x720 and used in runtime. |
| 2 | Built-in image generation | Title background in the same bright Japanese fairy-tale memory-backpack concept style. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a2125afaa64819584b1b8272781578e.png` | `reboot/assets/generated/mvp_art/title_background.png` | Normalized to 1280x720 and used in runtime. |
| 3 | Built-in image generation | Dialogue panel texture, stitched parchment and wood style, no text. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a21263d40d88195904ad2885d797b09.png` | `reboot/assets/generated/mvp_art/dialogue_panel.png` | Cropped and resized to 1140x150. |
| 4 | Built-in image generation | Button texture matching the concept material language, no text. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a212680465c819597f94f2fdc4007d3.png` | `reboot/assets/generated/mvp_art/button.png` | Cropped and resized to 260x58. |
| 5 | Built-in image generation | Ending/review background in the same forest-memory concept style. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a2126b0f5748195b22fc5a66d827fdd.png` | `reboot/assets/generated/mvp_art/ending_background.png` | Normalized to 1280x720 and used in runtime. |
| 6 | Built-in image generation | Chibi hero sprite on flat `#00ff00` chroma-key background, matching concept style. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a2126f192a88195a90cc637378c97a7.png` | `reboot/assets/generated/mvp_art/hero_chroma.png`, `reboot/assets/generated/mvp_art/hero.png` | Chroma key removed locally; transparent corners verified. |
| 7 | Built-in image generation | Chibi paper-memory enemy sprite on flat `#00ff00` chroma-key background, matching concept style. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a21273ba8e88195b8f388d5135a43d9.png` | `reboot/assets/generated/mvp_art/enemy_chroma.png`, `reboot/assets/generated/mvp_art/enemy.png` | Chroma key removed locally; transparent corners verified. |
| 8 | Built-in image generation | 4x4 memory item icon atlas in stitched parchment, cloth, wood, leaf and keepsake materials. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061a6194021e32d7016a21278437dc8195a183dd87c8de8987.png` | `reboot/assets/generated/mvp_art/memory_icons_atlas.png` | Normalized to 1024x1024 and used through `AtlasTexture`. |

## 2026-06-05

Total generated today for this MVP art fill: 2 / 50.

| # | Tool | Prompt Summary | Source Output | Workspace Asset | Status |
|---|---|---|---|---|---|
| 1 | Built-in image generation | 4x4 spatial memory backpack item sticker sheet: soup, sword, diary, tags, map, charm, ribbon, medal, lantern, wreath, glove; no text or grid lines. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_0f2aa71b89fd36df016a2249500ccc819885993bfac3f045e5.png` | `reboot/assets/generated/mvp_art/memory_item_sheet.png`, `reboot/assets/generated/mvp_art/memory_items/*.png` | Copied source sheet into workspace, cropped into 16 spatial item assets, and used by runtime before atlas fallback. |
| 2 | Built-in image generation | 3x3 ordered chibi hero walking spritesheet on flat green chroma key; frames ordered left-to-right, top-to-bottom. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_061327b67d142201016a22f184045881989d6d1497e6bb097a.png` | `reboot/assets/generated/mvp_art/actor_anim/hero_walk_sheet_chroma.png`, `reboot/assets/generated/mvp_art/actor_anim/hero_walk_sheet.png` | Chroma key removed locally, normalized to 768x768 3x3 grid, and runtime updated to read row-major frame order. |

## 2026-06-06

Total generated today for scrolling stage work: 1 / 50.

| # | Tool | Prompt Summary | Source Output | Workspace Asset | Status |
|---|---|---|---|---|---|
| 1 | Built-in image generation | Wide side-scrolling Japanese fairy-tale forest/tower stage background with a clean flat walkable ground band and no characters/UI/text. | `C:\Users\64844\.codex\generated_images\019e6a1f-c0b5-7ee2-9090-578ac0c0e509\ig_07f7b5f953f61e2e016a2300235d908198beb1e4ae71306155.png` | `reboot/assets/generated/mvp_art/scroll_stage_background_source.png`, `reboot/assets/generated/mvp_art/scroll_stage_background.png` | Copied source into workspace and cropped/resized to 2048x512 for runtime stage scrolling. |
