extends Control

const DESIGN_SIZE := Vector2(1280, 720)
const MVP_MEMORY_IDS := [
	"mem_mothers_soup",
	"mem_wooden_sword",
	"mem_reason_to_depart",
	"mem_my_name",
	"mem_someone_waits",
	"mem_abandoned_afternoon",
	"mem_no_more_explaining",
	"mem_empty_nameplate",
]

var layout: Dictionary = {}
var events: Array[Dictionary] = []
var memories: Dictionary = {}
var events_by_id: Dictionary = {}
var event_index_by_id: Dictionary = {}
var current_event_index := 0
var current_event: Dictionary = {}
var current_mode := "dialogue"
var owned_memory_ids: Array[String] = []
var discarded_memory_ids: Array[String] = []
var flags: Array[String] = []
var route_id := ""
var selected_ending_id := ""
var applied_event_effect_ids: Array[String] = []
var available_choice_options: Array[Dictionary] = []
var validation_errors: Array[String] = []

var bg_layer: ColorRect
var stage_panel: PanelContainer
var stage_label: Label
var floor_line: ColorRect
var hero_box: PanelContainer
var enemy_box: PanelContainer
var status_box: PanelContainer
var operation_tray: Control
var trash_zone: PanelContainer
var found_zone: PanelContainer
var inventory_grid: GridContainer
var inventory_cells: Array[PanelContainer] = []
var dialogue_panel: PanelContainer
var speaker_label: Label
var text_label: Label
var choice_panel: PanelContainer
var choice_list: VBoxContainer
var source_label: Label
var concept_reference: TextureRect
var title_layer: Control
var title_text_label: Label
var title_subtitle_label: Label
var title_concept_preview: TextureRect
var title_start_button: PanelContainer
var title_quit_button: PanelContainer
var title_note_panel: PanelContainer
var bag_detail_layer: Control
var bag_memory_list: PanelContainer
var bag_detail_panel: PanelContainer
var bag_detail_inventory: GridContainer
var bag_detail_cells: Array[PanelContainer] = []
var ending_layer: Control
var ending_summary_panel: PanelContainer
var ending_memory_panel: PanelContainer


func _ready() -> void:
	size = DESIGN_SIZE
	_load_layout()
	_load_source_script()
	_build_ui()
	show_mode("title")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if current_mode == "choice":
			var key_event := event as InputEventKey
			if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_9:
				choose_option(int(key_event.keycode - KEY_1))
				get_viewport().set_input_as_handled()
				return
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
			if current_mode == "title":
				start_script()
			elif current_mode in ["dialogue", "travel", "battle"]:
				advance_script()
			get_viewport().set_input_as_handled()


func show_mode(mode: String) -> void:
	current_mode = mode
	_apply_mode()


func jump_to_event(event_id: String) -> void:
	_go_to_event(event_id)


func start_script() -> void:
	_reset_script_state()
	_go_to_event(_first_event_id("T0001"))


func advance_script() -> void:
	if current_event.is_empty():
		start_script()
		return
	if _event_type(current_event) == "choice":
		if not available_choice_options.is_empty():
			choose_option(0)
		return
	var next_id := _next_playable_event_id(current_event_index + 1)
	if next_id.is_empty():
		show_mode("ending")
		return
	_go_to_event(next_id)


func choose_option(option_index: int) -> void:
	if option_index < 0 or option_index >= available_choice_options.size():
		return
	var option: Dictionary = available_choice_options[option_index]
	_apply_effects(option.get("effects", {}))
	var target_id := str(option.get("target", ""))
	if target_id == "EVAL_ENDING":
		_select_ending()
		return
	if target_id.is_empty():
		advance_script()
		return
	_go_to_event(target_id)


func owned_memory_count() -> int:
	return owned_memory_ids.size()


func discarded_memory_count() -> int:
	return discarded_memory_ids.size()


func has_memory(memory_id: String) -> bool:
	return owned_memory_ids.has(memory_id)


func has_discarded(memory_id: String) -> bool:
	return discarded_memory_ids.has(memory_id)


func has_flag(flag_id: String) -> bool:
	return flags.has(flag_id)


func loaded_event_count() -> int:
	return events.size()


func loaded_memory_count() -> int:
	return memories.size()


func _load_layout() -> void:
	layout = _load_json("res://data/layout_contract.json")
	if layout.is_empty():
		validation_errors.append("layout_contract.json failed to load")


func _load_source_script() -> void:
	var file := FileAccess.open("res://data/source_script.jsonl", FileAccess.READ)
	if file == null:
		validation_errors.append("source_script.jsonl failed to open")
		return
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var parsed = JSON.parse_string(line)
		if typeof(parsed) != TYPE_DICTIONARY:
			validation_errors.append("invalid JSONL line")
			continue
		var item: Dictionary = parsed
		if str(item.get("type", "")) == "memory_def":
			var memory_id := str(item.get("id", ""))
			if MVP_MEMORY_IDS.has(memory_id):
				memories[memory_id] = item
		elif item.has("id"):
			var event_id := str(item.get("id", ""))
			if ["T", "P", "F", "M", "C", "K", "E"].has(event_id.left(1)):
				events.append(item)
				events_by_id[event_id] = item
				event_index_by_id[event_id] = events.size() - 1
	_validate_loaded_source()


func _validate_loaded_source() -> void:
	for memory_id in MVP_MEMORY_IDS:
		if not memories.has(memory_id):
			validation_errors.append("missing MVP memory from source script: %s" % memory_id)
	for event_id in ["T0001", "T0002", "T0003", "P0034", "F0003", "F0010", "F0036"]:
		if not events_by_id.has(event_id):
			validation_errors.append("missing required MVP event from source script: %s" % event_id)


func _build_ui() -> void:
	bg_layer = ColorRect.new()
	bg_layer.color = Color(0.78, 0.84, 0.73)
	bg_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg_layer)

	concept_reference = TextureRect.new()
	_set_rect(concept_reference, Rect2(16, 80, 220, 124))
	concept_reference.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	concept_reference.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	concept_reference.modulate = Color(1, 1, 1, 0.26)
	_load_texture_rect(concept_reference, "res://assets/reference/concept_memory_backpack.png")
	add_child(concept_reference)

	stage_panel = _new_panel("stage")
	stage_label = _new_label(22, Color(0.18, 0.14, 0.10))
	add_child(stage_panel)

	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(stage_label)

	floor_line = ColorRect.new()
	floor_line.color = Color(0.20, 0.17, 0.12, 0.55)
	add_child(floor_line)

	hero_box = _new_panel("hero")
	hero_box.add_child(_center_label("主角占位"))
	add_child(hero_box)

	enemy_box = _new_panel("enemy")
	enemy_box.add_child(_center_label("敌人占位"))
	add_child(enemy_box)

	status_box = _new_panel("status")
	status_box.add_child(_center_label("战斗状态"))
	add_child(status_box)

	operation_tray = Control.new()
	add_child(operation_tray)

	var tray_bg := _new_panel("operation")
	tray_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	operation_tray.add_child(tray_bg)

	trash_zone = _new_panel("trash")
	trash_zone.add_child(_center_label("弃牌堆"))
	operation_tray.add_child(trash_zone)

	found_zone = _new_panel("found")
	found_zone.add_child(_center_label("新记忆"))
	operation_tray.add_child(found_zone)

	inventory_grid = GridContainer.new()
	operation_tray.add_child(inventory_grid)
	_build_inventory_cells()

	dialogue_panel = _new_panel("dialogue")
	add_child(dialogue_panel)

	var dialogue_margin := MarginContainer.new()
	dialogue_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_margin.add_theme_constant_override("margin_left", 28)
	dialogue_margin.add_theme_constant_override("margin_top", 16)
	dialogue_margin.add_theme_constant_override("margin_right", 28)
	dialogue_margin.add_theme_constant_override("margin_bottom", 14)
	dialogue_panel.add_child(dialogue_margin)

	var dialogue_box := VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 8)
	dialogue_margin.add_child(dialogue_box)

	speaker_label = _new_label(22, Color(0.22, 0.13, 0.06))
	dialogue_box.add_child(speaker_label)

	text_label = _new_label(22, Color(0.13, 0.10, 0.07))
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_box.add_child(text_label)

	choice_panel = _new_panel("dialogue")
	add_child(choice_panel)

	var choice_margin := MarginContainer.new()
	choice_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	choice_margin.add_theme_constant_override("margin_left", 14)
	choice_margin.add_theme_constant_override("margin_top", 14)
	choice_margin.add_theme_constant_override("margin_right", 14)
	choice_margin.add_theme_constant_override("margin_bottom", 14)
	choice_panel.add_child(choice_margin)

	choice_list = VBoxContainer.new()
	choice_list.add_theme_constant_override("separation", 8)
	choice_margin.add_child(choice_list)

	source_label = _new_label(16, Color(0.10, 0.10, 0.10, 0.75))
	source_label.text = "REBOOT graybox | source: original JSONL script | concept reference only"
	source_label.position = Vector2(20, 18)
	source_label.size = Vector2(760, 28)
	add_child(source_label)

	_build_title_layer()
	_build_bag_detail_layer()
	_build_ending_layer()


func _build_title_layer() -> void:
	title_layer = Control.new()
	title_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(title_layer)

	title_text_label = _new_label(44, Color(0.16, 0.10, 0.05))
	title_text_label.text = "记忆背包"
	title_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_layer.add_child(title_text_label)

	title_subtitle_label = _new_label(22, Color(0.24, 0.17, 0.10))
	title_subtitle_label.text = "重启灰盒：先锁定结构，再接入美术"
	title_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_layer.add_child(title_subtitle_label)

	title_concept_preview = TextureRect.new()
	title_concept_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_concept_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_concept_preview.modulate = Color(1, 1, 1, 0.78)
	_load_texture_rect(title_concept_preview, "res://assets/reference/concept_memory_backpack.png")
	title_layer.add_child(title_concept_preview)

	title_start_button = _new_panel("button")
	title_start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	title_start_button.gui_input.connect(_on_title_start_gui_input)
	title_start_button.add_child(_center_label("开始游戏"))
	title_layer.add_child(title_start_button)

	title_quit_button = _new_panel("button")
	title_quit_button.add_child(_center_label("退出占位"))
	title_layer.add_child(title_quit_button)

	title_note_panel = _new_panel("note")
	var note := _center_label("R2 规则：按原始 JSONL 脚本播放，不新增剧情。空格/回车推进，选择页可按数字键。")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_note_panel.add_child(note)
	title_layer.add_child(title_note_panel)


func _build_bag_detail_layer() -> void:
	bag_detail_layer = Control.new()
	bag_detail_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bag_detail_layer)

	var title := _new_label(32, Color(0.16, 0.10, 0.05))
	title.name = "BagDetailTitle"
	title.text = "背包详情灰盒"
	bag_detail_layer.add_child(title)

	var close_button := _new_panel("button")
	close_button.name = "BagDetailClose"
	close_button.add_child(_center_label("返回"))
	bag_detail_layer.add_child(close_button)

	bag_memory_list = _new_panel("note")
	bag_memory_list.add_child(_center_label("记忆列表\n来自原始脚本的 8 段 MVP 记忆"))
	bag_detail_layer.add_child(bag_memory_list)

	bag_detail_panel = _new_panel("dialogue")
	bag_detail_panel.add_child(_center_label("记忆详情\n关系对象 / 承诺 / 丢弃后世界回应"))
	bag_detail_layer.add_child(bag_detail_panel)

	bag_detail_inventory = GridContainer.new()
	bag_detail_layer.add_child(bag_detail_inventory)
	_build_detail_inventory_cells()


func _build_detail_inventory_cells() -> void:
	var inventory: Dictionary = layout.get("inventory", {})
	var grid = inventory.get("grid", [7, 4])
	var gap = inventory.get("gap", [8, 8])
	var columns := int(grid[0])
	var rows := int(grid[1])
	var unlocked := int(inventory.get("initial_unlocked_slots", 4))
	bag_detail_inventory.columns = columns
	bag_detail_inventory.add_theme_constant_override("h_separation", int(gap[0]))
	bag_detail_inventory.add_theme_constant_override("v_separation", int(gap[1]))
	var board_rect := _screen_rect("bag_detail", "inventory_board")
	var cell_size := _inventory_cell_size(board_rect, Vector2i(columns, rows), Vector2(float(gap[0]), float(gap[1])))
	for index in range(columns * rows):
		var cell := _new_panel("cell_unlocked" if index < unlocked else "cell_locked")
		cell.custom_minimum_size = cell_size
		cell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var label := _center_label(str(index + 1) if index < unlocked else "锁")
		label.add_theme_font_size_override("font_size", 16 if index < unlocked else 13)
		cell.add_child(label)
		bag_detail_cells.append(cell)
		bag_detail_inventory.add_child(cell)


func _build_ending_layer() -> void:
	ending_layer = Control.new()
	ending_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ending_layer)

	var title := _new_label(38, Color(0.16, 0.10, 0.05))
	title.name = "EndingTitle"
	title.text = "MVP 回顾灰盒"
	ending_layer.add_child(title)

	ending_summary_panel = _new_panel("dialogue")
	ending_summary_panel.add_child(_center_label("结局摘要\n名字是否保留\n出发理由是否保留\n世界如何回应"))
	ending_layer.add_child(ending_summary_panel)

	ending_memory_panel = _new_panel("note")
	ending_memory_panel.add_child(_center_label("最终背包\n保留记忆 / 丢弃记忆 / 核心记忆状态"))
	ending_layer.add_child(ending_memory_panel)

	var restart_button := _new_panel("button")
	restart_button.name = "EndingRestart"
	restart_button.add_child(_center_label("重新开始"))
	ending_layer.add_child(restart_button)

	var title_button := _new_panel("button")
	title_button.name = "EndingTitleButton"
	title_button.add_child(_center_label("回标题"))
	ending_layer.add_child(title_button)


func _build_inventory_cells() -> void:
	var inventory: Dictionary = layout.get("inventory", {})
	var grid = inventory.get("grid", [7, 4])
	var gap = inventory.get("gap", [8, 8])
	var columns := int(grid[0])
	var rows := int(grid[1])
	var unlocked := int(inventory.get("initial_unlocked_slots", 4))
	inventory_grid.columns = columns
	inventory_grid.add_theme_constant_override("h_separation", int(gap[0]))
	inventory_grid.add_theme_constant_override("v_separation", int(gap[1]))
	var board_rect := _screen_rect("travel", "inventory_board")
	var cell_size := _inventory_cell_size(board_rect, Vector2i(columns, rows), Vector2(float(gap[0]), float(gap[1])))
	for index in range(columns * rows):
		var cell := _new_panel("cell_unlocked" if index < unlocked else "cell_locked")
		cell.custom_minimum_size = cell_size
		cell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var label := _center_label(str(index + 1) if index < unlocked else "锁")
		label.add_theme_font_size_override("font_size", 16 if index < unlocked else 13)
		cell.add_child(label)
		inventory_cells.append(cell)
		inventory_grid.add_child(cell)


func _go_to_event(event_id: String) -> void:
	var event: Dictionary = events_by_id.get(event_id, {})
	if event.is_empty():
		return
	current_event = event
	current_event_index = int(event_index_by_id.get(event_id, events.find(event)))
	available_choice_options.clear()
	speaker_label.text = str(event.get("speaker", ""))
	text_label.text = str(event.get("text", ""))
	_apply_event_effects_if_needed(event)
	var event_type := _event_type(event)
	if event_type == "choice":
		available_choice_options = _available_options(event)
		_rebuild_choice_list()
		current_mode = "choice"
	elif event_type == "battle":
		current_mode = "battle"
	elif event_type.begins_with("memory_"):
		current_mode = "travel"
	else:
		current_mode = "dialogue"
	_apply_mode()


func _reset_script_state() -> void:
	current_event = {}
	current_event_index = 0
	owned_memory_ids.clear()
	discarded_memory_ids.clear()
	flags.clear()
	route_id = ""
	selected_ending_id = ""
	applied_event_effect_ids.clear()
	available_choice_options.clear()


func _event_type(event: Dictionary) -> String:
	return str(event.get("type", ""))


func _next_playable_event_id(start_index: int) -> String:
	for index in range(max(0, start_index), events.size()):
		var event: Dictionary = events[index]
		if _conditions_met(str(event.get("condition", ""))):
			return str(event.get("id", ""))
	return ""


func _apply_event_effects_if_needed(event: Dictionary) -> void:
	var event_id := str(event.get("id", ""))
	if event_id.is_empty() or applied_event_effect_ids.has(event_id):
		return
	if event.has("effects"):
		_apply_effects(event.get("effects", {}))
		applied_event_effect_ids.append(event_id)


func _available_options(event: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var options = event.get("options", [])
	if typeof(options) != TYPE_ARRAY:
		return result
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			continue
		var typed_option: Dictionary = option
		if _requirements_met(str(typed_option.get("requires", ""))):
			result.append(typed_option)
	return result


func _rebuild_choice_list() -> void:
	for child in choice_list.get_children():
		child.queue_free()
	for index in range(available_choice_options.size()):
		var option: Dictionary = available_choice_options[index]
		var option_button := Button.new()
		option_button.text = "%d. %s" % [index + 1, str(option.get("label", ""))]
		option_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		option_button.add_theme_font_size_override("font_size", 16)
		option_button.pressed.connect(choose_option.bind(index))
		choice_list.add_child(option_button)


func _apply_effects(effects_value) -> void:
	if typeof(effects_value) != TYPE_DICTIONARY:
		return
	var effects: Dictionary = effects_value
	_add_memories(_string_array(effects.get("gain", [])))
	_discard_memories(_string_array(effects.get("discard", [])))
	_discard_memories(_string_array(effects.get("consume", [])), false)
	_add_flags(_string_array(effects.get("set_flags", [])))
	if effects.has("set_route"):
		route_id = str(effects.get("set_route", ""))


func _add_memories(memory_ids: Array[String]) -> void:
	for memory_id in memory_ids:
		if memory_id.is_empty() or owned_memory_ids.has(memory_id):
			continue
		owned_memory_ids.append(memory_id)


func _discard_memories(memory_ids: Array[String], mark_discarded := true) -> void:
	for memory_id in memory_ids:
		owned_memory_ids.erase(memory_id)
		if mark_discarded and not discarded_memory_ids.has(memory_id):
			discarded_memory_ids.append(memory_id)


func _add_flags(flag_ids: Array[String]) -> void:
	for flag_id in flag_ids:
		if not flag_id.is_empty() and not flags.has(flag_id):
			flags.append(flag_id)


func _conditions_met(condition_text: String) -> bool:
	return _requirements_met(condition_text)


func _requirements_met(requirements_text: String) -> bool:
	if requirements_text.strip_edges().is_empty():
		return true
	for requirement in requirements_text.split(",", false):
		if not _single_requirement_met(requirement.strip_edges()):
			return false
	return true


func _single_requirement_met(requirement: String) -> bool:
	if requirement.is_empty():
		return true
	if requirement.begins_with("has_memory:"):
		return has_memory(requirement.trim_prefix("has_memory:"))
	if requirement.begins_with("not_has_memory:"):
		return not has_memory(requirement.trim_prefix("not_has_memory:"))
	if requirement.begins_with("discarded:"):
		return has_discarded(requirement.trim_prefix("discarded:"))
	if requirement.begins_with("not_discarded:"):
		return not has_discarded(requirement.trim_prefix("not_discarded:"))
	if requirement.begins_with("has_flag:"):
		return has_flag(requirement.trim_prefix("has_flag:"))
	if requirement.begins_with("not_has_flag:"):
		return not has_flag(requirement.trim_prefix("not_has_flag:"))
	if requirement.begins_with("route:"):
		return route_id == requirement.trim_prefix("route:")
	if requirement.begins_with("ending:"):
		return selected_ending_id == requirement.trim_prefix("ending:")
	if requirement.begins_with("score:"):
		return _score_requirement_met(requirement.trim_prefix("score:"))
	return true


func _score_requirement_met(requirement: String) -> bool:
	var operators := [">=", "<=", ">", "<", "=="]
	for operator in operators:
		var parts := requirement.split(operator, false, 1)
		if parts.size() == 2:
			var tag := parts[0].strip_edges()
			var expected := int(parts[1].strip_edges())
			var actual := _memory_tag_score(tag)
			match operator:
				">=":
					return actual >= expected
				"<=":
					return actual <= expected
				">":
					return actual > expected
				"<":
					return actual < expected
				"==":
					return actual == expected
	return false


func _memory_tag_score(tag: String) -> int:
	var score := 0
	for memory_id in owned_memory_ids:
		var memory: Dictionary = memories.get(memory_id, {})
		var tags = memory.get("tags", [])
		if typeof(tags) == TYPE_ARRAY and tags.has(tag):
			score += 1
	return score


func _select_ending() -> void:
	if route_id == "accept_discarded" and has_memory("mem_reason_to_depart") and has_memory("mem_my_name") and _memory_tag_score("温柔") >= 2:
		selected_ending_id = "reconciliation"
	elif route_id == "go_home" and has_memory("mem_want_to_go_home"):
		selected_ending_id = "homecoming"
	elif route_id == "kill_demon" and not has_memory("mem_reason_to_depart"):
		selected_ending_id = "hollow"
	elif route_id == "kill_demon" and not has_memory("mem_my_name"):
		selected_ending_id = "nameless"
	elif route_id == "kill_demon" and has_memory("mem_reason_to_depart") and has_memory("mem_my_name"):
		selected_ending_id = "hero"
	else:
		selected_ending_id = "hollow"
	var ending_event_id := _next_playable_event_id(int(event_index_by_id.get("E0001", events.size())))
	if ending_event_id.is_empty():
		show_mode("ending")
	else:
		_go_to_event(ending_event_id)


func _apply_mode() -> void:
	stage_panel.visible = current_mode == "travel" or current_mode == "battle"
	stage_label.visible = stage_panel.visible
	floor_line.visible = stage_panel.visible
	hero_box.visible = current_mode == "travel" or current_mode == "battle"
	enemy_box.visible = current_mode == "battle"
	status_box.visible = current_mode == "battle"
	operation_tray.visible = current_mode == "travel" or current_mode == "battle"
	dialogue_panel.visible = current_mode == "dialogue" or current_mode == "choice"
	choice_panel.visible = current_mode == "choice"
	title_layer.visible = current_mode == "title"
	bag_detail_layer.visible = current_mode == "bag_detail"
	ending_layer.visible = current_mode == "ending"
	concept_reference.visible = false
	if current_mode == "title":
		_apply_title_layout()
	elif current_mode == "choice":
		_apply_choice_layout()
	elif current_mode == "bag_detail":
		_apply_bag_detail_layout()
	elif current_mode == "ending":
		_apply_ending_layout()
	elif current_mode == "battle":
		_apply_battle_layout()
	elif current_mode == "travel":
		_apply_travel_layout()
	else:
		_apply_dialogue_layout()


func _apply_dialogue_layout() -> void:
	_set_rect(dialogue_panel, _screen_rect("dialogue", "dialogue_panel"))
	_set_rect(concept_reference, Rect2(16, 80, 220, 124))


func _apply_choice_layout() -> void:
	_set_rect(dialogue_panel, _screen_rect("dialogue", "dialogue_panel"))
	_set_rect(choice_panel, _screen_rect("choice", "choice_panel"))


func _on_title_start_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_script()


func _string_array(value) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) == TYPE_ARRAY:
		for item in value:
			result.append(str(item))
	elif typeof(value) == TYPE_STRING and not str(value).is_empty():
		result.append(str(value))
	return result


func _apply_title_layout() -> void:
	_set_rect(title_text_label, _screen_rect("title", "title_text"))
	_set_rect(title_subtitle_label, _screen_rect("title", "subtitle_text"))
	_set_rect(title_concept_preview, _screen_rect("title", "concept_preview"))
	_set_rect(title_start_button, _screen_rect("title", "primary_button"))
	_set_rect(title_quit_button, _screen_rect("title", "quit_button"))
	_set_rect(title_note_panel, _screen_rect("title", "note_panel"))


func _apply_bag_detail_layout() -> void:
	_set_rect(bag_detail_layer.get_node("BagDetailTitle"), _screen_rect("bag_detail", "title"))
	_set_rect(bag_detail_layer.get_node("BagDetailClose"), _screen_rect("bag_detail", "close_button"))
	_set_rect(bag_memory_list, _screen_rect("bag_detail", "memory_list"))
	_set_rect(bag_detail_panel, _screen_rect("bag_detail", "detail_panel"))
	_set_rect(bag_detail_inventory, _screen_rect("bag_detail", "inventory_board"))


func _apply_ending_layout() -> void:
	_set_rect(ending_layer.get_node("EndingTitle"), _screen_rect("ending", "title"))
	_set_rect(ending_summary_panel, _screen_rect("ending", "summary_panel"))
	_set_rect(ending_memory_panel, _screen_rect("ending", "memory_panel"))
	_set_rect(ending_layer.get_node("EndingRestart"), _screen_rect("ending", "restart_button"))
	_set_rect(ending_layer.get_node("EndingTitleButton"), _screen_rect("ending", "title_button"))


func _apply_travel_layout() -> void:
	_set_rect(stage_panel, _screen_rect("travel", "stage"))
	_set_rect(stage_label, Rect2(_screen_rect("travel", "stage").position + Vector2(26, 16), Vector2(620, 34)))
	_set_rect(floor_line, _screen_rect("travel", "floor_baseline"))
	_set_rect(hero_box, _screen_rect("travel", "hero"))
	_set_operation_layout("travel")
	stage_label.text = "行走灰盒舞台：主角必须踩在基线附近"


func _apply_battle_layout() -> void:
	_set_rect(stage_panel, _screen_rect("battle", "stage"))
	_set_rect(stage_label, Rect2(_screen_rect("battle", "stage").position + Vector2(26, 16), Vector2(620, 34)))
	_set_rect(floor_line, _screen_rect("battle", "floor_baseline"))
	_set_rect(hero_box, _screen_rect("battle", "hero"))
	_set_rect(enemy_box, _screen_rect("battle", "enemy"))
	_set_rect(status_box, _screen_rect("battle", "status"))
	_set_operation_layout("battle")
	stage_label.text = "战斗灰盒舞台：左主角 / 右敌人 / 同一地面"


func _set_operation_layout(screen_id: String) -> void:
	var tray_rect := _screen_rect(screen_id, "operation_tray")
	_set_rect(operation_tray, tray_rect)
	_set_rect(trash_zone, _relative_rect(_screen_rect(screen_id, "trash_zone"), tray_rect.position))
	_set_rect(found_zone, _relative_rect(_screen_rect(screen_id, "found_zone"), tray_rect.position))
	_set_rect(inventory_grid, _relative_rect(_screen_rect(screen_id, "inventory_board"), tray_rect.position))


func _screen_rect(screen_id: String, section_id: String) -> Rect2:
	var screens: Dictionary = layout.get("screens", {})
	var screen: Dictionary = screens.get(screen_id, {})
	return _rect_from_array(screen.get(section_id, [0, 0, 0, 0]))


func _relative_rect(rect: Rect2, origin: Vector2) -> Rect2:
	return Rect2(rect.position - origin, rect.size)


func _inventory_cell_size(board_rect: Rect2, grid_size: Vector2i, gap: Vector2) -> Vector2:
	var width := board_rect.size.x - gap.x * float(max(0, grid_size.x - 1))
	var height := board_rect.size.y - gap.y * float(max(0, grid_size.y - 1))
	return Vector2(floor(width / float(grid_size.x)), floor(height / float(grid_size.y)))


func _rect_from_array(values) -> Rect2:
	if typeof(values) != TYPE_ARRAY or values.size() != 4:
		return Rect2()
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


func _set_rect(control: Control, rect: Rect2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = rect.position
	control.size = rect.size


func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		return {}
	var parsed = JSON.parse_string(text)
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _load_texture_rect(texture_rect: TextureRect, path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	if image.load(path) != OK:
		return
	texture_rect.texture = ImageTexture.create_from_image(image)


func _new_panel(kind: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	match kind:
		"stage":
			style.bg_color = Color(0.88, 0.82, 0.64, 0.72)
			style.border_color = Color(0.32, 0.25, 0.13, 0.9)
		"hero":
			style.bg_color = Color(0.35, 0.62, 0.86, 0.78)
			style.border_color = Color(0.12, 0.26, 0.40, 1.0)
		"enemy":
			style.bg_color = Color(0.74, 0.40, 0.47, 0.78)
			style.border_color = Color(0.36, 0.12, 0.16, 1.0)
		"status":
			style.bg_color = Color(0.92, 0.86, 0.68, 0.84)
			style.border_color = Color(0.32, 0.22, 0.10, 1.0)
		"operation":
			style.bg_color = Color(0.72, 0.61, 0.43, 0.74)
			style.border_color = Color(0.26, 0.18, 0.09, 1.0)
		"trash":
			style.bg_color = Color(0.78, 0.70, 0.54, 0.86)
			style.border_color = Color(0.42, 0.22, 0.16, 1.0)
		"found":
			style.bg_color = Color(0.46, 0.58, 0.62, 0.86)
			style.border_color = Color(0.18, 0.28, 0.32, 1.0)
		"cell_locked":
			style.bg_color = Color(0.42, 0.42, 0.38, 0.82)
			style.border_color = Color(0.18, 0.18, 0.16, 1.0)
		"dialogue":
			style.bg_color = Color(0.94, 0.88, 0.73, 0.94)
			style.border_color = Color(0.30, 0.20, 0.10, 1.0)
		_:
			style.bg_color = Color(0.88, 0.80, 0.62, 0.90)
			style.border_color = Color(0.42, 0.31, 0.18, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _center_label(text: String) -> Label:
	var label := _new_label(18, Color(0.10, 0.08, 0.06))
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	return label


func _new_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _first_event_id(fallback: String) -> String:
	return fallback if events_by_id.has(fallback) else str(events[0].get("id", "")) if not events.is_empty() else ""
