from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "source" / "记忆背包_MVP数据表_v0.2_主题校准版.txt"
OUTPUTS = [
    "script_extract_mvp.json",
    "memories.json",
    "enemies.json",
    "chapter_flow.json",
    "balance.json",
    "mvp_endings.json",
]


def main() -> int:
    text = SOURCE.read_text(encoding="utf-8")
    blocks = re.findall(r"```json\s*(.*?)\s*```", text, flags=re.S)
    if len(blocks) < len(OUTPUTS):
        raise SystemExit(f"Expected at least {len(OUTPUTS)} JSON blocks, found {len(blocks)}")

    data_dir = ROOT / "data"
    data_dir.mkdir(exist_ok=True)

    for filename, block in zip(OUTPUTS, blocks):
        parsed = json.loads(block)
        target = data_dir / filename
        target.write_text(
            json.dumps(parsed, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"wrote {target.relative_to(ROOT)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
