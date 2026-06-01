from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
JSON_FILES = [
    "balance.json",
    "chapter_flow.json",
    "enemies.json",
    "memories.json",
    "mvp_endings.json",
    "script_extract_mvp.json",
]


def main() -> int:
    data_dir = ROOT / "data"
    for filename in JSON_FILES:
        json.loads((data_dir / filename).read_text(encoding="utf-8"))
        print(f"valid JSON: data/{filename}")

    count = 0
    for line_no, line in enumerate((data_dir / "script_events_mvp.jsonl").read_text(encoding="utf-8").splitlines(), 1):
        if not line.strip():
            continue
        json.loads(line)
        count += 1
    print(f"valid JSONL: data/script_events_mvp.jsonl ({count} events)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
