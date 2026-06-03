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
var current_event_index := 0
var current_mode := "dialogue"
var owned_memory_ids: Array[String] = []
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
var source_label: Label
var concept_reference: TextureRect


func _ready() -> void:
	size = DESIGN_SIZE
	_load_layout()
	_load_source_script()
	_build_ui()
	_apply_event(_first_event_id("T0001"))


func show_mode(mode: String) -> void:
	current_mode = mode
	_apply_mode()


func jump_to_event(event_id: String) -> void:
	_apply_event(event_id)


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
			if event_id.begins_with("T") or event_id.begins_with("P") or event_id.begins_with("F"):
				events.append(item)
				events_by_id[event_id] = item
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

	source_label = _new_label(16, Color(0.10, 0.10, 0.10, 0.75))
	source_label.text = "REBOOT graybox | source: original JSONL script | concept reference only"
	source_label.position = Vector2(20, 18)
	source_label.size = Vector2(760, 28)
	add_child(source_label)


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


func _apply_event(event_id: String) -> void:
	var event: Dictionary = events_by_id.get(event_id, {})
	if event.is_empty():
		return
	current_event_index = events.find(event)
	speaker_label.text = str(event.get("speaker", ""))
	text_label.text = str(event.get("text", ""))
	if str(event.get("type", "")) == "battle":
		current_mode = "battle"
	elif str(event.get("chapter", "")) == "forest" and str(event.get("type", "")) != "line":
		current_mode = "travel"
	else:
		current_mode = "dialogue"
	_apply_mode()


func _apply_mode() -> void:
	stage_panel.visible = current_mode != "dialogue"
	stage_label.visible = current_mode != "dialogue"
	floor_line.visible = current_mode != "dialogue"
	hero_box.visible = current_mode != "dialogue"
	enemy_box.visible = current_mode == "battle"
	status_box.visible = current_mode == "battle"
	operation_tray.visible = current_mode != "dialogue"
	dialogue_panel.visible = current_mode == "dialogue"
	if current_mode == "battle":
		_apply_battle_layout()
	elif current_mode == "travel":
		_apply_travel_layout()
	else:
		_apply_dialogue_layout()


func _apply_dialogue_layout() -> void:
	_set_rect(dialogue_panel, _screen_rect("dialogue", "dialogue_panel"))
	_set_rect(concept_reference, Rect2(16, 80, 220, 124))


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
