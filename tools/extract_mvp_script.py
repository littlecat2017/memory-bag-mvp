from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "docs" / "source" / "记忆背包_完整脚本_JSONL_v1.3_完整主题统一版.txt"
TARGET = ROOT / "data" / "script_events_mvp.jsonl"
RANGES = {
    "P": (1, 37),
    "F": (1, 40),
}
EXPECTED_EVENT_COUNT = 83


def include_event_id(event_id: str) -> bool:
    match = re.match(r"^([PF])(\d{4})[A-Z]?$", event_id)
    if match is None:
        return False
    prefix = match.group(1)
    number = int(match.group(2))
    start, end = RANGES[prefix]
    return start <= number <= end


def main() -> int:
    selected: list[str] = []
    for raw_line in SOURCE.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line:
            continue
        record = json.loads(line)
        event_id = record.get("id", "")
        if include_event_id(event_id):
            selected.append(line)

    if len(selected) != EXPECTED_EVENT_COUNT:
        raise SystemExit(
            f"Expected {EXPECTED_EVENT_COUNT} MVP script events, found {len(selected)}"
        )

    TARGET.parent.mkdir(exist_ok=True)
    TARGET.write_text("\n".join(selected) + "\n", encoding="utf-8")
    print(f"wrote {TARGET.relative_to(ROOT)} ({len(selected)} events)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
