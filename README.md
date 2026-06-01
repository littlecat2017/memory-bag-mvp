# 记忆背包

Godot MVP project for 《记忆背包》.

Current MVP scope is defined by the source documents in `docs/source/`.
Implementation should stay inside MVP-1 unless the design documents are updated:

- 序章：故乡
- 第一章：遗忘森林
- 自动行进
- 自动战斗
- 4 格记忆背包
- 背包替换与核心记忆二次确认
- 忘名猎人 Boss 前献名选择
- 名字/出发理由组合的 MVP 结尾

Do not improvise story text. Script events are extracted from
`docs/source/记忆背包_完整脚本_JSONL_v1.3_完整主题统一版.txt`.

Image generation policy:

- Maximum 50 generated images per day.
- Log every generated image in `logs/image_generation.jsonl`.
- Never commit or print API keys, account passwords, tokens, or temporary secret URLs.
