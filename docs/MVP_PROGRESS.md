# 《记忆背包》MVP 开发规划与完成度

更新时间：2026-06-02

本文档用于跟踪 MVP-1 开发进度。每完成一轮开发，都要更新本文件中的模块状态、总完成度、已完成内容、下一步任务，然后提交并推送。

## 1. 范围边界

当前只做 MVP-1，严格以 `docs/source/` 中的设计文档为准。

MVP-1 包含：

- 序章：故乡。
- 第一章：遗忘森林，1000m。
- 自动行进。
- 自动战斗。
- 4 格记忆背包。
- 记忆获得、放弃、丢弃、替换。
- 核心记忆二次确认。
- JSONL 脚本播放。
- `choice.options[].effects` 执行。
- 3 场普通战斗。
- 1 场 Boss：忘名猎人。
- 最小世界反馈：名字栏、关系回应、结尾分支。
- 调试面板。

MVP-1 暂不做：

- 记忆合成。
- 第二章、第三章、终章。
- 完整五结局。
- 离线收益。
- 复杂商店。
- 成就。
- 装备系统。
- 技能树。
- 正式音频系统。
- 正式美术资源管线。

## 2. 当前总完成度

当前完成度：95%

计算方式：按模块权重估算，不按文件数量估算。完成度只在对应验收标准通过后增加。

## 3. 模块权重表

| 模块 | 权重 | 状态 | 当前完成 | 剩余工作 | 验收标准 |
| --- | ---: | --- | ---: | --- | --- |
| M0 空工程与数据校验 | 10% | 完成 | 10% | 无 | Godot 启动后数据加载成功，`validation_errors=0` |
| M1 脚本播放器 | 12% | 基本完成 | 11% | `tutorial` 类型的专门表现、少量体验打磨 | 可从 `P0001` 播放到 `P0037`；森林节点可按段播放 |
| M2 记忆背包与替换 | 18% | 基本完成 | 16% | 替换界面视觉打磨、可交互丢弃入口 | `F0010` 满包时能替换或放弃，丢弃反馈区分 |
| M3 自动行进 | 12% | 完成 MVP 验收 | 12% | 章节结束后的正式跳转表现可继续打磨 | 从森林 0m 自动推进到 1000m，行进中显示 Q 版小窗，战斗完成后能恢复行进并继续触发后续节点 |
| M4 自动战斗 | 16% | 完成 MVP 验收 | 16% | 濒死回退与 faded 状态、战斗演出二次打磨 | 木剑提高攻击；有人等我恢复；空名牌对无名敌人更强；标准 MVP 路线可胜利打过 Boss 并进入结尾，战斗中显示 Q 版双方和基础攻击动画 |
| M5 世界反馈 | 12% | 基本完成 | 10% | 反馈日志 UI 打磨、Boss 条件台词表现、结尾界面打磨 | 丢热汤后空碗文本变化；丢名字后 Boss 和结尾不再叫艾尔 |
| M6 Boss 与 MVP 结尾 | 10% | 完成 | 10% | 完整流程手动体验校验、Boss 名字主题演出二次打磨 | 至少跑出 4 种 MVP 结尾；标准路线可从开局跑到 `mvp_named_with_reason` |
| M7 存档与调试 | 6% | 基本完成 | 5% | 调试面板视觉打磨、更多运行态快捷开关、存档槽位 UI | 30 秒内跳到 `P0034/F0010/F0021/F0034/F0040`；可保存并恢复关键运行状态 |
| M8 MVP 美术接入 | 4% | 完成 | 4% | 更多记忆图标、场景差分、UI 皮肤二次精修 | 资源路径稳定，图片生成有日志，不超过每日 50 张 |

## 4. 已完成内容

### 2026-06-01

- 创建 Godot 4.6 项目。
- 创建 GitHub 仓库并推送。
- 复制 6 份源设计文档到 `docs/source/`。
- 从设计文档生成 `data/*.json`。
- 从完整 JSONL 脚本文档提取 MVP 脚本：`P0001-P0037`、`F0001-F0040`，共 83 条事件。
- 实现 `DataRegistry`。
- 实现数据校验：
  - 记忆 ID。
  - 敌人 ID。
  - 脚本事件 ID。
  - `choice target`。
  - `effects gain/discard/consume` 的记忆引用。
  - 章节节点事件引用。
  - MVP 结尾条件引用。
  - 记忆关系字段完整性。
- 实现 `GameState`。
- 实现 `ScriptPlayer`。
- 实现最小剧情 UI：
  - 当前事件 ID。
  - 背景 ID。
  - 立绘 ID。
  - 说话人。
  - 原文文本。
  - 名字栏。
  - 背包摘要。
  - 选择按钮。
- 自动验证脚本 `scripts/debug/verify_prologue.gd` 通过：
  - 标准开局从 `P0001` 到 `P0037`。
  - 标准开局获得 4 张初始记忆。
  - 轻装开局丢弃 `mem_mothers_soup`。
  - 分支合流到 `P0036/P0037`。
- 实现 4 格记忆卡 UI `MemoryCardView`。
- 记忆卡显示：
  - 名称。
  - 标签。
  - 数值效果。
  - 关系对象。
  - 承诺摘要。
  - 丢弃后果提示。
- 主界面背包从摘要文本升级为 4 格卡片。
- 自动验证脚本 `scripts/debug/verify_memory_cards.gd` 通过，确认 8 张 MVP 记忆都能显示关系、承诺和丢弃提示。
- 实现满包替换流程：
  - 标准开局背包满时，拾取 `mem_someone_waits` 会进入待替换状态。
  - 支持丢弃旧记忆并接受新记忆。
  - 支持放弃新记忆。
  - 丢弃核心记忆时显示二次确认文本。
  - 丢弃 `mem_my_name` 后名字栏变为“勇者”。
- 实现丢弃世界反馈记录 `world_feedback_history`。
- 实现森林自动行进控制器 `RunController`：
  - 使用 `chapter_flow.json` 的 `progress` 触发节点。
  - 事件播放时暂停行进。
  - 节点结束后恢复行进。
  - 支持调试跳转到指定距离。
- 主界面显示当前章节和距离。
- 自动验证脚本 `scripts/debug/verify_memory_replacement.gd` 通过：
  - 标准开局满包替换路径。
  - 轻装开局直接获得新记忆路径。
- 自动验证脚本 `scripts/debug/verify_run_flow.gd` 通过，确认森林节点按顺序触发：
  - `forest_intro`
  - `forest_battle_01`
  - `forest_memory_choice_01`
  - `forest_camp_and_memory`
  - `forest_battle_02`
  - `forest_shrine_and_boss_choice`
  - `forest_boss`
  - `forest_after_boss`
- 实现 `GameState` 的玩家数值字段：
  - 等级、经验、金币、记忆碎片。
  - 当前生命与基础属性。
  - 战斗结果与战斗日志缓存。
- 实现记忆驱动的派生属性计算：
  - 普通属性加成。
  - 百分比属性加成。
  - 等级成长。
  - `target_has_tag` / `source_has_tag` 条件修正。
- 实现自动战斗运行器 `BattleRunner`：
  - 按 `enemy_id` 队列逐个模拟战斗。
  - 玩家自动攻击间隔 `2.0 / speed`。
  - 敌人按表配置自动攻击。
  - 伤害随机浮动、暴击、最低伤害保护。
  - 胜利奖励别名结算。
  - 战斗日志记录。
- 接入记忆战斗效果：
  - `mem_wooden_sword` 提高攻击并增加普通攻击固定伤害。
  - `mem_someone_waits` 每 5 秒恢复生命。
  - `mem_mothers_soup` 战后恢复生命。
  - `mem_abandoned_afternoon` 提高攻击并降低受治疗量。
  - `mem_no_more_explaining` 提高攻击，并降低来自 `silent` 敌人的伤害。
  - `mem_empty_nameplate` 提高暴击率，并提高对 `nameless` 敌人的伤害。
  - 核心记忆提供 `memory_resist`。
- 接入敌人机制：
  - 无名鹿每 10 秒下一次攻击伤害提高。
  - 空壳巡林人低血量时防御提高一次。
  - 忘名猎人在 `gave_name_to_hunter` 标记下开战生命降低。
  - 忘名猎人对保留名字的压力先记录为日志，MVP 第一版暂不实际淡化记忆。
- 主流程中 `battle` 事件从脚本占位改为真实自动战斗：
  - `F0003`、`F0023`、`F0036` 会调用战斗运行器。
  - 战斗胜利后标记事件已完成并恢复自动行进。
  - 主界面显示战斗日志、HP、等级、金币。
- 新增自动验证脚本 `scripts/debug/verify_battle.gd` 通过：
  - 木剑提高伤害。
  - 有人等我触发周期恢复。
  - 空名牌提高对无名敌人与忘名猎人的伤害。
  - 不再解释降低沉默敌人的伤害。
  - `F0003` 胜利后正确获得经验、金币、记忆碎片。
- 新增自动验证脚本 `scripts/debug/verify_run_battle_flow.gd` 通过：
  - 森林战斗节点完成后可以继续触发下一个行进节点。
- 修正脚本播放器的分段停止规则：
  - 分支合流目标如果超出当前节点 `end_event_id`，不会越过行进节点提前播放后续内容。
  - Boss 前拒绝献名分支会停在当前脚本段，不会绕过 `forest_boss` 战斗节点。
- 实现 `EndingRunner`：
  - 使用 `data/mvp_endings.json` 的规则按优先级判定 MVP 结尾。
  - 支持 `has_memory`、`not_has_memory`、`discarded`、`not_discarded`、`has_flag`、`not_has_flag`、`route` 条件。
  - 只播放数据表中的 `lines`，不新增剧本文本。
- 主流程接入 MVP 结尾：
  - `forest_after_boss` 播放完 `F0040` 后进入结尾判定。
  - 主界面可逐行播放结尾文本。
  - `GameState` 记录当前结尾和结尾历史。
- 新增自动验证脚本 `scripts/debug/verify_mvp_endings.gd` 通过：
  - 名字保留 + 理由保留 -> `mvp_named_with_reason`。
  - 名字保留 + 理由丢失 -> `mvp_named_without_reason`。
  - 名字丢失 + 理由保留 -> `mvp_nameless_with_reason`。
  - 名字丢失 + 理由丢失 -> `mvp_nameless_without_reason`。
  - Boss 前献出名字会丢弃 `mem_my_name`、获得 `mem_empty_nameplate`、设置 `gave_name_to_hunter` 并擦除名字栏。
- 实现本地存档 `SaveManager`：
  - 默认保存到 `user://save_slot_1.json`。
  - 保存 `GameState`、`RunController`、`ScriptPlayer` 和少量 UI 上下文。
  - 不保存派生属性 `DerivedStats`，读档后按当前数据重新计算。
- `GameState` 支持保存和恢复：
  - 背包、丢弃/消耗/发现记忆。
  - 生命、等级、经验、金币、记忆碎片。
  - 旗标、路线、当前事件、已看事件、关键选择历史。
  - 世界反馈、战斗结果、结尾记录。
- `RunController` 支持保存和恢复：
  - 当前章节。
  - 当前进度。
  - 已触发行进节点。
  - 行进/暂停状态。
- 主界面增加调试面板：
  - 保存、读取。
  - 快速跳到 `P0034/F0010/F0021/F0034/F0040`。
  - 添加/移除常用 MVP 记忆。
  - 强制进入四种 MVP 结尾。
- 新增自动验证脚本 `scripts/debug/verify_save_debug.gd` 通过：
  - 存档恢复背包、丢弃记录、HP、金币、旗标、章节进度、已触发节点、脚本播放器状态和 UI 上下文。
  - 调试跳转能直接到达 `P0034/F0010/F0021/F0034/F0040`。
- 建立 MVP 美术资源表 `data/art_assets.json`：
  - 首批登记 6 个风格测试资源。
  - 为暂未生成的村庄/森林背景和角色表情配置别名回退，避免剧情 UI 空白。
- 使用桌面 image2 PHP 脚本生成首批 6 张美术资源，并写入 `logs/image_generation.jsonl`：
  - `bg_village_dawn`
  - `bg_forest_path`
  - `hero_default`
  - `mother_warm`
  - `icon_memory_mothers_soup`
  - `fx_slash_basic_sheet`
- 主界面接入美术预览：
  - 剧情事件按 `bg` 显示背景图。
  - 剧情事件按 `portrait` 显示立绘图。
  - 战斗结果界面复用当前背景图。
  - MVP 结尾逐行播放时复用背景/立绘资源。
- 记忆卡接入图标资源：
  - `mem_mothers_soup` 会显示“母亲做的热汤”图标。
  - 未配置图标的记忆仍保持文字卡片，不阻断流程。
- `DataRegistry` 增加美术资源校验：
  - 校验资源类型。
  - 校验文件路径存在。
  - 校验 `expected_size` 格式。
  - 校验记忆图标引用的 `memory_id`。
- `tools/validate_json_data.py` 纳入 `data/art_assets.json`。
- 新增自动验证脚本 `scripts/debug/verify_art_assets.gd`：
  - 校验 6 个资源 id。
  - 校验别名解析。
  - 校验 PNG 能被 Godot `Image.load` 读取。
  - 校验记忆卡图标和主界面背景/立绘预览。
- 修复 PNG 资源在 headless/新环境中用 `load(res://*.png)` 无法读取的问题：
  - 主界面背景/立绘改为 `Image.load` + `ImageTexture.create_from_image`。
  - 记忆卡图标改为 `Image.load` + `ImageTexture.create_from_image`。
- 使用便携 Godot 4.6.3 运行完整自动验收：
  - `verify_prologue.gd`
  - `verify_memory_cards.gd`
  - `verify_memory_replacement.gd`
  - `verify_run_flow.gd`
  - `verify_battle.gd`
  - `verify_run_battle_flow.gd`
  - `verify_mvp_endings.gd`
  - `verify_save_debug.gd`
  - `verify_art_assets.gd`
- 新增完整通关冒烟脚本 `scripts/debug/verify_full_game_flow.gd`：
  - 标准开局保留 4 段初始记忆。
  - 森林首战胜利。
  - `F0010` 满包时拾取“有人等我”，丢弃“母亲做的热汤”。
  - 营火选择不拾取“不再解释”。
  - 第二场战斗胜利。
  - Boss 前拒绝献出名字。
  - Boss 战胜利。
  - Boss 后获得“空名牌”时仍遵守 4 格背包限制，需要替换旧记忆。
  - 跑到 `mvp_named_with_reason` 结尾。
- 校准 MVP 自动战斗数值：
  - 降低空壳巡林人攻击压力。
  - 降低忘名猎人生命与攻击压力。
  - “有人等我”的周期恢复从 2 点提高到 4 点。
  - 标准完整路线验收结果：`ending=mvp_named_with_reason hp=21 gold=34`，最终背包保持 4 格。
- 改造主界面为视觉小说式布局：
  - 全屏背景图作为第一视觉层。
  - 底部使用 image2 生成的对话框 UI 皮肤。
  - 对话框左上角使用角色名牌 UI。
  - 选择项改为居中浮层，不再挤在底部文本区。
  - 顶部只保留玩家状态、章节进度、背包/保存/读取/调试入口，事件 ID 和背景 ID 不再出现在正式界面。
  - 调试面板默认隐藏，只通过“调试”按钮展开。
- 生成并接入 4 张视觉小说 UI 皮肤，均已写入 `logs/image_generation.jsonl`：
  - `ui_dialogue_box`
  - `ui_nameplate`
  - `ui_choice_button`
  - `ui_bag_panel`
- 本地处理立绘透明化：
  - `portrait_hero_default_cutout.png`
  - `portrait_mother_warm_cutout.png`
  - 资源表已切换到抠图版立绘，不额外消耗 image2 额度。
- 背包侧栏改为可折叠右侧面板：
  - 使用 image2 生成的背包面板底图。
  - 4 格记忆卡改为纵向滚动显示，避免遮挡底部对话框。
- 新增 UI 截图验收脚本 `scripts/debug/capture_ui_snapshots.gd`：
  - 导出开场、初始记忆选择、背包面板三张截图到 `temp/ui_snapshots/`。
  - 使用 `SubViewport` 固定 1280x720 逻辑画布，避免 Windows/Godot 高 DPI 截图偏移。
- 项目显示配置加入 viewport stretch 与关闭 HiDPI，减少不同窗口缩放下 UI 锚点错位风险。
- 使用便携 Godot 4.6.3 重新运行完整自动验收，全部通过：
  - `verify_prologue.gd`
  - `verify_memory_cards.gd`
  - `verify_memory_replacement.gd`
  - `verify_run_flow.gd`
  - `verify_battle.gd`
  - `verify_run_battle_flow.gd`
  - `verify_mvp_endings.gd`
  - `verify_save_debug.gd`
  - `verify_art_assets.gd`
  - `verify_full_game_flow.gd`

### 2026-06-02

- 回顾 `docs/source/` 中的战斗与 UI 要求：战斗应作为记忆构筑的压力来源，自动推进为主，表现需要清楚但不能抢走“记忆关系凭证”的主题。
- `BattleRunner` 增加战斗演出时间线 `timeline`，在不改变数值结算的前提下记录：
  - 敌人出现。
  - 勇者攻击。
  - 敌人反击。
  - 记忆恢复。
  - 敌人蓄力、防御与 Boss 压力提示。
  - 敌人击败、濒死与复活。
- 主界面增加战斗演出层：
  - 左侧显示勇者立绘，右侧显示敌人面板。
  - 敌人面板显示名称、HP 条和 HP 数字。
  - 中央显示遭遇、挥剑、反击、恢复等战斗状态。
  - 勇者攻击时会向前突进，敌人受击时会震动并变色。
  - 敌人反击时敌人前压，勇者受击闪红。
  - 伤害和恢复以浮字显示。
- 接入已有 `fx_slash_basic_sheet`，按 3x3 图集切出 9 帧，在勇者攻击时播放斩击特效。
- 战斗结束前等待演出播放完毕再恢复自动行进，避免战斗画面一闪而过。
- 固定战斗双方初始站位并在演出结束后复位，避免连续攻击动画导致位置漂移。
- 战斗结果对话框改为两行重点摘要，优先显示胜负结果和战斗奖励，避免日志压住视觉小说对话框边缘。
- `scripts/debug/verify_battle.gd` 增加时间线验收，确认 `F0003` 至少产生敌人出现、玩家攻击和敌人击败事件。
- `scripts/debug/capture_ui_snapshots.gd` 增加 `04_battle_stage.png` 截图，用于验收战斗舞台、敌人面板和底部日志布局。
- 本轮未调用 image2 生成新图片，图片生成消耗不变。
- 使用便携 Godot 4.6.3 重新运行完整自动验收，全部通过：
  - `verify_prologue.gd`
  - `verify_memory_cards.gd`
  - `verify_memory_replacement.gd`
  - `verify_run_flow.gd`
  - `verify_battle.gd`
  - `verify_run_battle_flow.gd`
  - `verify_mvp_endings.gd`
  - `verify_save_debug.gd`
  - `verify_art_assets.gd`
  - `verify_full_game_flow.gd`
- 重新导出 UI 截图，确认 `temp/ui_snapshots/04_battle_stage.png` 中战斗舞台可见，底部摘要不再压边。
- 新增 MVP 结尾通关回顾层：
  - 读完结尾文本后显示正式结算页。
  - 回顾名字是否保留、出发理由是否保留。
  - 列出当前保留记忆、丢失记忆、HP、等级、金币和记忆碎片。
  - 只使用当前运行状态和既有数据表，不新增或改写 `mvp_endings.json` 剧本文本。
- 新增调试/演出保护：强制跳转或进入结尾时会取消仍在播放的战斗演出，避免旧伤害浮字、敌人面板残留在结算页背后。
- 新增 UI 验收脚本 `scripts/debug/verify_ending_summary_ui.gd`，逐一强制四种 MVP 结尾并验证结算页标题、保留记忆列表和丢失记忆列表。
- `scripts/debug/capture_ui_snapshots.gd` 增加 `05_ending_summary.png`，用于肉眼验收结尾回顾层。
- 再次运行完整自动验收，新增 `verify_ending_summary_ui.gd` 后全部通过。
- 为战斗舞台增加敌人视觉身份：
  - 根据敌人标签区分空壳、无名、沉默和 Boss。
  - 空壳狼群、无名鹿、空壳巡林人、忘名猎人会显示不同符号、标签、面板色调和边框色。
  - 忘名猎人使用红色 Boss 面板、弓符号、`Boss / 无名 / 空壳` 标签和名字被拉向弓弦的压迫提示。
- `BattleRunner` 的演出时间线增加 `enemy_tags` 字段，UI 不再只依赖敌人名字猜测表现。
- 修正战斗舞台的坐标布局，避免调试跳转或截图时敌人面板复位到左上角。
- `scripts/debug/verify_battle.gd` 增加 Boss 时间线标签验收，确认 `F0036` 的演出事件带有 `boss` 和 `nameless` 标签。
- `scripts/debug/capture_ui_snapshots.gd` 增加 `05_boss_battle_stage.png`，结尾回顾截图顺延为 `06_ending_summary.png`。
- 本轮仍未调用 image2，图片生成消耗不变。
- 回顾 `docs/source/记忆背包_MVP美术资源规划_v0.1.txt`，按 MVP 第一批和当前脚本缺口补齐关键人物与敌人资源。
- 使用桌面 image2 PHP 脚本生成并记录 11 张新图，均写入 `logs/image_generation.jsonl`，本日用量为 11 / 50：
  - `master_old`
  - `lia_sick`
  - `elder_gray`
  - `child_lost`
  - `camp_shadow`
  - `hunter_hollow`
  - `hunter_human`
  - `enemy_hollow_wolves`
  - `enemy_nameless_deer`
  - `enemy_hollow_warden`
  - `boss_nameless_hunter`
- 使用本地绿幕抠图流程生成透明 PNG，并保留最终项目资产：
  - `assets/portraits/portrait_master_old_cutout.png`
  - `assets/portraits/portrait_lia_sick_cutout.png`
  - `assets/portraits/portrait_elder_gray_cutout.png`
  - `assets/portraits/portrait_child_lost_cutout.png`
  - `assets/portraits/portrait_camp_shadow_cutout.png`
  - `assets/portraits/portrait_hunter_hollow_cutout.png`
  - `assets/portraits/portrait_hunter_human_cutout.png`
  - `assets/enemies/enemy_hollow_wolves_cutout.png`
  - `assets/enemies/enemy_nameless_deer_cutout.png`
  - `assets/enemies/enemy_hollow_warden_cutout.png`
  - `assets/enemies/enemy_boss_nameless_hunter_cutout.png`
- 更新 `data/art_assets.json`：
  - 母亲立绘不再作为师父、莉娅、长老、迷路孩子、营火人影、猎人的别名。
  - 新增 7 个独立剧情立绘资源。
  - 新增 `enemy` 类型并登记 4 个敌人/Boss 战斗单位资源。
  - `memory_lia` 暂时复用 `lia_sick`，不再复用母亲。
- 战斗舞台右侧面板从敌人 id 读取 `enemy` 贴图，优先显示正式敌人图，符号身份保留为加载失败兜底。
- `scripts/debug/verify_art_assets.gd` 增加角色去复用、敌人资源加载、战斗舞台敌人贴图显示验收。
- 重新运行 JSON 校验和完整 Godot 自动验收，全部通过；并用 Windows 显示驱动重新导出 UI 截图，确认 `04_battle_stage.png` 和 `05_boss_battle_stage.png` 中真实敌人图片可见。
- 按新的演出设计补齐 Q 版行进与战斗表现，保持全屏场景背景不变，在上层叠加一个小型行进窗口：
  - 行进窗口使用独立 UI 底图，里面显示道路与 Q 版主角团。
  - Q 版主角团使用 3x3 九宫格行走图，随森林进度沿小窗道路横向移动。
  - 行进窗口在战斗与结尾层打开时自动隐藏，避免压住主要流程。
- 战斗舞台从“左立绘/右敌人面板”调整为“左侧 Q 版主角团、右侧 Q 版敌人/Boss”：
  - 左侧保留半透明主角立绘作为氛围层，Q 版角色作为真正行动单位站在地面上。
  - 右侧敌人面板只保留名称、类型、HP 条和数值，不再重复显示旧的大敌人图。
  - 普通敌人和 Boss 均使用独立 Q 版战斗单位贴图。
  - 勇者攻击时播放 Q 版前冲挥剑九宫格，并继续叠加已有斩击特效、受击位移和伤害浮字。
- 使用桌面 image2 PHP 脚本生成并记录 7 张新图，均写入 `logs/image_generation.jsonl`，本日用量更新为 18 / 50：
  - `chibi_party_walk_sheet`
  - `chibi_hero_attack_sheet`
  - `chibi_enemy_hollow_wolves`
  - `chibi_enemy_nameless_deer`
  - `chibi_enemy_hollow_warden`
  - `chibi_boss_nameless_hunter`
  - `ui_travel_stage_panel`
- `data/art_assets.json` 增加 `chibi_sheet`、`chibi_unit` 与行进小窗 UI 资源登记；`DataRegistry` 同步允许这些资源类型。
- `scripts/debug/verify_art_assets.gd` 增加 Q 版资源解析、行进小窗可见性、战斗 Q 版主角与敌人可见性验收。
- `scripts/debug/capture_ui_snapshots.gd` 调整截图顺序：
  - `04_travel_stage.png`
  - `05_battle_stage.png`
  - `06_boss_battle_stage.png`
  - `07_ending_summary.png`
- 重新运行 JSON 校验、资源验收和 UI 截图导出，均通过；肉眼检查确认行进小窗不再遮挡右侧剧情立绘主体，战斗中 Q 版双方站在道路地面上。

## 5. 近期开发顺序

### 下一轮：最终 MVP 试玩包收口

目标：

- 使用调试面板和手动点击复核完整流程。
- 检查调试入口、存档入口、截图和导出配置，确保试玩包不会暴露不必要的开发状态。
- 打磨主界面布局、战斗日志、结尾回顾细节，并准备最终 exe 打包前的验收清单。

验收：

- 从新开局手动跑到至少一种 MVP 结尾，并与 `verify_full_game_flow.gd` 结果一致。
- 常用调试跳转不超过 30 秒到达目标节点。
- 截图中主界面、战斗舞台、背包面板、选择浮层和结尾回顾层都没有明显遮挡或文本溢出。
- 若生成新图，图片日志完整且不记录任何密钥或临时敏感 URL。

### 再下一轮：MVP 后续扩展评估

目标：

- 根据试玩反馈决定是否继续扩展第二章、更多记忆、更多敌人与音频系统。
- 检查 Q 版角色、立绘、敌人和 UI 风格一致性，决定是否进入下一批美术批量生成。
- 梳理正式版本需要移除或隐藏的调试能力。

验收：

- MVP 试玩包反馈明确。
- 下一阶段范围不偏离 `docs/source/` 中的核心设计。
- 单日 image2 额度继续遵守 50 张上限。

## 6. 图片生成计划

当前累计已登记图片：28 张。

2026-06-02 本日图片生成消耗：18 / 50 张。

已生成并登记的 28 张图片：

1. `bg_village_dawn`
2. `bg_forest_path`
3. `hero_default`
4. `mother_warm`
5. `icon_memory_mothers_soup`
6. `fx_slash_basic_sheet`
7. `ui_dialogue_box`
8. `ui_nameplate`
9. `ui_choice_button`
10. `ui_bag_panel`
11. `master_old`
12. `lia_sick`
13. `elder_gray`
14. `child_lost`
15. `camp_shadow`
16. `hunter_hollow`
17. `hunter_human`
18. `enemy_hollow_wolves`
19. `enemy_nameless_deer`
20. `enemy_hollow_warden`
21. `boss_nameless_hunter`
22. `chibi_party_walk_sheet`
23. `chibi_hero_attack_sheet`
24. `chibi_enemy_hollow_wolves`
25. `chibi_enemy_nameless_deer`
26. `chibi_enemy_hollow_warden`
27. `chibi_boss_nameless_hunter`
28. `ui_travel_stage_panel`

后续生成规则：

- 每生成一张，必须写入 `logs/image_generation.jsonl`。
- 不记录密钥、账号密码、token 或临时敏感 URL。
- 单日最多 50 张。
- 未确认风格前，不进入 36 张第一批美术批量生成。
- 本日剩余可用额度：32 张；下一轮优先做体验验收和打包收口，不主动扩大生成量。

## 7. 每轮更新规则

每轮开发完成后必须做：

1. 回顾 `docs/source/` 相关文档，确认没有偏离。
2. 更新本文档：
   - 当前总完成度。
   - 模块状态。
   - 已完成内容。
   - 下一步计划。
   - 图片生成消耗。
3. 运行对应验证。
4. 检查敏感信息。
5. 提交并推送。

## 8. 当前风险

- 自动战斗已接入基础演出时间线、斩击播放、Q 版双方站位、正式敌人图片和 Boss 压迫提示，但仍缺少失败惩罚视觉反馈。
- 濒死回退与 faded 状态尚未完整实现，失败惩罚目前只做复活记录。
- Boss 后 MVP 结尾已接入通关回顾层；Boss 本体已有首批正式战斗图片和基础压迫表现，但仍缺少更完整的名字主题演出。
- 调试面板功能可用且默认隐藏，但视觉仍偏工具化，后续应随正式 UI 一起整理。
- 首批真实美术资源、敌人战斗图、Q 版行进/战斗图和视觉小说 UI 皮肤已接入，立绘与敌人图已做本地透明化初版；边缘精度后续仍可继续抠图或重生透明背景版本。
- `fx_slash_basic_sheet` 已生成、登记并接入战斗演出播放；后续可根据实际观感重新生成更干净的透明特效表。
- 已可用便携 Godot 4.6.3 运行 headless 验证；本机全局 PATH 仍未配置 Godot。
