extends Control

const DESIGN_SIZE := Vector2(1280, 720)
const POINTER_HOLD_INITIAL_DELAY := 0.35
const POINTER_HOLD_REPEAT_INTERVAL := 0.16
const DRAG_START_THRESHOLD := 8.0
const MEMORY_ITEM_INSET := Vector2.ZERO
const ART_ROOT := "res://assets/generated/mvp_art/"
const ART_GAMEPLAY_SHELL := ART_ROOT + "gameplay_shell.png"
const ART_TITLE_BACKGROUND := ART_ROOT + "title_background.png"
const ART_DIALOGUE_PANEL := ART_ROOT + "dialogue_panel.png"
const ART_BUTTON := ART_ROOT + "button.png"
const ART_ENDING_BACKGROUND := ART_ROOT + "ending_background.png"
const ART_HERO := ART_ROOT + "hero.png"
const ART_ENEMY := ART_ROOT + "enemy.png"
const ART_ACTOR_ANIM_ROOT := ART_ROOT + "actor_anim/"
const ART_HERO_WALK_SHEET := ART_ACTOR_ANIM_ROOT + "hero_walk_sheet.png"
const ART_HERO_ATTACK_SHEET := ART_ACTOR_ANIM_ROOT + "hero_attack_sheet.png"
const ART_ENEMY_IDLE_SHEET := ART_ACTOR_ANIM_ROOT + "enemy_idle_sheet.png"
const ART_ENEMY_HIT_SHEET := ART_ACTOR_ANIM_ROOT + "enemy_hit_sheet.png"
const ART_SLASH_EFFECT_SHEET := ART_ACTOR_ANIM_ROOT + "slash_effect_sheet.png"
const ART_HIT_BURST_SHEET := ART_ACTOR_ANIM_ROOT + "hit_burst_sheet.png"
const ART_MEMORY_ICONS_ATLAS := ART_ROOT + "memory_icons_atlas.png"
const ART_MEMORY_ITEM_ROOT := ART_ROOT + "memory_items/"
const ACTOR_ANIM_FRAME_SIZE := Vector2i(256, 256)
const SLASH_ANIM_FRAME_SIZE := Vector2i(256, 160)
const HIT_BURST_ANIM_FRAME_SIZE := Vector2i(192, 192)
const WALK_FRAME_TIME := 0.11
const ATTACK_FRAME_TIME := 0.075
const ENEMY_IDLE_FRAME_TIME := 0.13
const ENEMY_HIT_FRAME_TIME := 0.07
const SLASH_FRAME_TIME := 0.055
const HIT_BURST_FRAME_TIME := 0.045
const HERO_WALK_FRAMES := 9
const HERO_WALK_SHEET_COLUMNS := 3
const HERO_ATTACK_FRAMES := 8
const ENEMY_HIT_FRAMES := 6
const ACTOR_LOOP_FRAMES := 8
const SLASH_FRAMES := 6
const HIT_BURST_FRAMES := 8
const OPENING_TRAVEL_TARGET_METERS := 100.0
const OPENING_TRAVEL_SPEED_METERS := 22.0
const BATTLE_HERO_MAX_HP := 30
const BATTLE_ENEMY_MAX_HP := 24
const BATTLE_BOSS_MAX_HP := 36
const BATTLE_PLAYER_DAMAGE := 10
const BATTLE_ENEMY_DAMAGE := 5
const BATTLE_ENEMY_RESPONSE_DELAY := 0.28
const BATTLE_ENEMY_ATTACK_DURATION := 0.42
const BATTLE_HERO_HIT_DURATION := 0.34
const ART_ASSET_PATHS := [
	ART_GAMEPLAY_SHELL,
	ART_TITLE_BACKGROUND,
	ART_DIALOGUE_PANEL,
	ART_BUTTON,
	ART_ENDING_BACKGROUND,
	ART_HERO,
	ART_ENEMY,
	ART_HERO_WALK_SHEET,
	ART_HERO_ATTACK_SHEET,
	ART_ENEMY_IDLE_SHEET,
	ART_ENEMY_HIT_SHEET,
	ART_SLASH_EFFECT_SHEET,
	ART_HIT_BURST_SHEET,
	ART_MEMORY_ICONS_ATLAS,
]
const REQUIRED_MEMORY_IDS := [
	"mem_mothers_soup",
	"mem_wooden_sword",
	"mem_reason_to_depart",
	"mem_my_name",
	"mem_someone_waits",
	"mem_abandoned_afternoon",
	"mem_no_more_explaining",
	"mem_empty_nameplate",
]
const MEMORY_ICON_IDS := {
	"mem_mothers_soup": 0,
	"mem_wooden_sword": 1,
	"mem_reason_to_depart": 2,
	"mem_my_name": 3,
	"mem_someone_waits": 5,
	"mem_abandoned_afternoon": 8,
	"mem_no_more_explaining": 7,
	"mem_empty_nameplate": 13,
	"mem_masters_scolding": 8,
	"mem_battle_instinct": 9,
	"mem_prove_with_wound": 15,
	"mem_rusty_victory": 11,
	"mem_rain_lamp": 12,
	"mem_want_to_go_home": 14,
	"mem_crown_without_name": 11,
	"mem_not_let_go": 15,
}
const MEMORY_ICON_ATLAS_COLUMNS := 4
const MEMORY_ICON_ATLAS_ROWS := 4
const MEMORY_GRID_SIZES := {
	"mem_mothers_soup": Vector2i(1, 1),
	"mem_wooden_sword": Vector2i(4, 1),
	"mem_reason_to_depart": Vector2i(2, 3),
	"mem_my_name": Vector2i(2, 1),
	"mem_someone_waits": Vector2i(2, 1),
	"mem_abandoned_afternoon": Vector2i(2, 1),
	"mem_no_more_explaining": Vector2i(2, 1),
	"mem_empty_nameplate": Vector2i(2, 1),
	"mem_masters_scolding": Vector2i(1, 2),
	"mem_battle_instinct": Vector2i(2, 2),
	"mem_prove_with_wound": Vector2i(2, 2),
	"mem_rusty_victory": Vector2i(1, 1),
	"mem_rain_lamp": Vector2i(1, 2),
	"mem_want_to_go_home": Vector2i(2, 2),
	"mem_crown_without_name": Vector2i(1, 1),
	"mem_not_let_go": Vector2i(2, 2),
}
const MEMORY_ITEM_ART_PATHS := {
	"mem_mothers_soup": ART_MEMORY_ITEM_ROOT + "mem_mothers_soup.png",
	"mem_wooden_sword": ART_MEMORY_ITEM_ROOT + "mem_wooden_sword.png",
	"mem_reason_to_depart": ART_MEMORY_ITEM_ROOT + "mem_reason_to_depart.png",
	"mem_my_name": ART_MEMORY_ITEM_ROOT + "mem_my_name.png",
	"mem_someone_waits": ART_MEMORY_ITEM_ROOT + "mem_someone_waits.png",
	"mem_abandoned_afternoon": ART_MEMORY_ITEM_ROOT + "mem_abandoned_afternoon.png",
	"mem_no_more_explaining": ART_MEMORY_ITEM_ROOT + "mem_no_more_explaining.png",
	"mem_empty_nameplate": ART_MEMORY_ITEM_ROOT + "mem_empty_nameplate.png",
	"mem_masters_scolding": ART_MEMORY_ITEM_ROOT + "mem_masters_scolding.png",
	"mem_battle_instinct": ART_MEMORY_ITEM_ROOT + "mem_battle_instinct.png",
	"mem_prove_with_wound": ART_MEMORY_ITEM_ROOT + "mem_prove_with_wound.png",
	"mem_rusty_victory": ART_MEMORY_ITEM_ROOT + "mem_rusty_victory.png",
	"mem_rain_lamp": ART_MEMORY_ITEM_ROOT + "mem_rain_lamp.png",
	"mem_want_to_go_home": ART_MEMORY_ITEM_ROOT + "mem_want_to_go_home.png",
	"mem_crown_without_name": ART_MEMORY_ITEM_ROOT + "mem_crown_without_name.png",
	"mem_not_let_go": ART_MEMORY_ITEM_ROOT + "mem_not_let_go.png",
}
const MEMORY_DEFAULT_POSITIONS := {
	"mem_mothers_soup": Vector2i(0, 0),
	"mem_wooden_sword": Vector2i(1, 0),
	"mem_reason_to_depart": Vector2i(5, 0),
	"mem_my_name": Vector2i(0, 1),
	"mem_someone_waits": Vector2i(2, 1),
	"mem_abandoned_afternoon": Vector2i(2, 2),
	"mem_no_more_explaining": Vector2i(0, 2),
	"mem_empty_nameplate": Vector2i(3, 3),
	"mem_masters_scolding": Vector2i(4, 1),
	"mem_battle_instinct": Vector2i(2, 2),
	"mem_prove_with_wound": Vector2i(3, 2),
	"mem_rusty_victory": Vector2i(6, 3),
	"mem_rain_lamp": Vector2i(0, 2),
	"mem_want_to_go_home": Vector2i(3, 1),
	"mem_crown_without_name": Vector2i(6, 3),
	"mem_not_let_go": Vector2i(4, 2),
}

var layout: Dictionary = {}
var events: Array[Dictionary] = []
var memories: Dictionary = {}
var events_by_id: Dictionary = {}
var event_index_by_id: Dictionary = {}
var current_event_index := 0
var current_event: Dictionary = {}
var current_mode := "dialogue"
var owned_memory_ids: Array[String] = []
var memory_grid_positions: Dictionary = {}
var discarded_memory_ids: Array[String] = []
var flags: Array[String] = []
var route_id := ""
var selected_ending_id := ""
var applied_event_effect_ids: Array[String] = []
var available_choice_options: Array[Dictionary] = []
var pending_gain_memory_ids: Array[String] = []
var pending_resume_event_id := ""
var opening_travel_active := false
var opening_travel_meters := 0.0
var battle_active := false
var battle_resolved := false
var battle_turns := 0
var battle_enemy_id := ""
var battle_reward_ids: Array[String] = []
var battle_phase := ""
var battle_action_text := ""
var battle_enemy_response_elapsed := 0.0
var hero_hp := 0
var hero_max_hp := BATTLE_HERO_MAX_HP
var enemy_hp := 0
var enemy_max_hp := BATTLE_ENEMY_MAX_HP
var pointer_hold_active := false
var pointer_hold_elapsed := 0.0
var pointer_hold_next_at := 0.0
var last_story_mode := "dialogue"
var drag_active := false
var drag_moved := false
var drag_source_kind := ""
var drag_source_slot := -1
var drag_memory_id := ""
var drag_origin_position := Vector2i(-1, -1)
var drag_start_position := Vector2.ZERO
var validation_errors: Array[String] = []

var bg_layer: ColorRect
var screen_background_art: TextureRect
var stage_panel: PanelContainer
var stage_label: Label
var floor_line: ColorRect
var hero_box: PanelContainer
var hero_art: TextureRect
var enemy_box: PanelContainer
var enemy_art: TextureRect
var enemy_box_label: Label
var slash_effect_art: TextureRect
var hit_burst_art: TextureRect
var status_box: ColorRect
var status_box_art: TextureRect
var status_box_label: Label
var operation_tray: Control
var trash_zone: PanelContainer
var trash_zone_icon: TextureRect
var trash_zone_label: Label
var found_zone: PanelContainer
var found_zone_icon: TextureRect
var found_zone_label: Label
var inventory_grid: GridContainer
var inventory_item_layer: Control
var inventory_cells: Array[PanelContainer] = []
var inventory_cell_labels: Array[Label] = []
var inventory_cell_icons: Array[TextureRect] = []
var dialogue_panel: PanelContainer
var dialogue_panel_art: TextureRect
var speaker_label: Label
var text_label: Label
var choice_panel: PanelContainer
var choice_panel_art: TextureRect
var choice_list: VBoxContainer
var source_label: Label
var concept_reference: TextureRect
var travel_progress_back: ColorRect
var travel_progress_fill: ColorRect
var title_layer: Control
var title_background_art: TextureRect
var title_text_label: Label
var title_subtitle_label: Label
var title_concept_preview: TextureRect
var title_start_button: PanelContainer
var title_quit_button: PanelContainer
var title_note_panel: PanelContainer
var bag_detail_layer: Control
var bag_detail_background_art: TextureRect
var bag_detail_close_button: PanelContainer
var bag_memory_list: PanelContainer
var bag_detail_panel: PanelContainer
var bag_detail_inventory: GridContainer
var bag_detail_item_layer: Control
var bag_detail_cells: Array[PanelContainer] = []
var bag_detail_cell_icons: Array[TextureRect] = []
var ending_layer: Control
var ending_background_art: TextureRect
var ending_summary_panel: PanelContainer
var ending_summary_label: Label
var ending_memory_panel: PanelContainer
var ending_memory_label: Label
var ending_restart_button: PanelContainer
var ending_title_button: PanelContainer
var drag_preview: PanelContainer
var drag_preview_icon: TextureRect
var drag_preview_label: Label
var memory_icons_texture: Texture2D
var memory_item_textures: Dictionary = {}
var hero_static_texture: Texture2D
var enemy_static_texture: Texture2D
var hero_walk_sheet_texture: Texture2D
var hero_attack_sheet_texture: Texture2D
var enemy_idle_sheet_texture: Texture2D
var enemy_hit_sheet_texture: Texture2D
var slash_effect_sheet_texture: Texture2D
var hit_burst_sheet_texture: Texture2D
var hero_walk_frames: Array[Texture2D] = []
var hero_attack_frames: Array[Texture2D] = []
var enemy_idle_frames: Array[Texture2D] = []
var enemy_hit_frames: Array[Texture2D] = []
var slash_effect_frames: Array[Texture2D] = []
var hit_burst_frames: Array[Texture2D] = []
var hero_base_rect := Rect2()
var enemy_base_rect := Rect2()
var hero_animation_elapsed := 0.0
var enemy_animation_elapsed := 0.0
var hero_attack_elapsed := 0.0
var enemy_hit_elapsed := 0.0
var slash_elapsed := 0.0
var hit_burst_elapsed := 0.0
var enemy_attack_elapsed := 0.0
var hero_hit_elapsed := 0.0
var hero_attack_active := false
var enemy_hit_active := false
var enemy_attack_active := false
var hero_hit_active := false
var slash_active := false
var hit_burst_active := false
var hit_burst_target := "enemy"


func _ready() -> void:
	size = DESIGN_SIZE
	_load_layout()
	_load_source_script()
	_build_ui()
	show_mode("title")
	_refresh_inventory_ui()


func _process(delta: float) -> void:
	_update_actor_animations(delta)
	_update_battle_turn_flow(delta)
	_update_opening_travel(delta)
	if drag_active:
		var pointer_position := get_viewport().get_mouse_position()
		drag_moved = drag_moved or pointer_position.distance_to(drag_start_position) >= DRAG_START_THRESHOLD
		_update_drag_preview_position(pointer_position)
	if pointer_hold_active:
		if not _can_pointer_advance():
			_stop_pointer_hold()
			return
		pointer_hold_elapsed += delta
		if pointer_hold_elapsed >= pointer_hold_next_at:
			_advance_by_pointer()
			pointer_hold_next_at += POINTER_HOLD_REPEAT_INTERVAL


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_stop_pointer_hold()
			if drag_active:
				_finish_drag(mouse_event.position)
				get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_progress_mouse_event(event as InputEventMouseButton)
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		if current_mode == "memory_replace":
			if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_9:
				replace_memory_at(int(key_event.keycode - KEY_1))
				get_viewport().set_input_as_handled()
				return
		if current_mode == "choice":
			if key_event.keycode >= KEY_1 and key_event.keycode <= KEY_9:
				choose_option(int(key_event.keycode - KEY_1))
				get_viewport().set_input_as_handled()
				return
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
			if current_mode == "title":
				start_script()
			elif current_mode == "battle":
				advance_battle()
			elif current_mode in ["dialogue", "travel", "ending"]:
				advance_script()
			get_viewport().set_input_as_handled()


func show_mode(mode: String) -> void:
	current_mode = mode
	_apply_mode()


func open_bag_detail() -> void:
	if current_mode != "bag_detail":
		last_story_mode = current_mode
	show_mode("bag_detail")


func return_to_story() -> void:
	if last_story_mode.is_empty() or last_story_mode == "bag_detail":
		last_story_mode = "dialogue"
	show_mode(last_story_mode)


func jump_to_event(event_id: String) -> void:
	_go_to_event(event_id)


func start_script() -> void:
	_reset_script_state()
	_grant_standard_opening_memories()
	opening_travel_active = true
	opening_travel_meters = 0.0
	current_mode = "travel"
	last_story_mode = "travel"
	current_event = {}
	current_event_index = int(event_index_by_id.get("F0003", 0))
	_refresh_inventory_ui()
	_apply_mode()


func start_source_script() -> void:
	_reset_script_state()
	_go_to_event(_first_event_id("T0001"))


func advance_script() -> void:
	if opening_travel_active:
		return
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


func advance_battle() -> void:
	if current_mode != "battle":
		return
	if _battle_animation_active():
		return
	if battle_resolved:
		advance_script()
		return
	if battle_phase == "enemy":
		_perform_enemy_battle_turn()
	elif battle_phase == "player":
		_perform_player_battle_turn()
	else:
		return


func _update_opening_travel(delta: float) -> void:
	if not opening_travel_active or current_mode != "travel":
		return
	opening_travel_meters = min(OPENING_TRAVEL_TARGET_METERS, opening_travel_meters + OPENING_TRAVEL_SPEED_METERS * delta)
	_refresh_opening_travel_ui()
	if opening_travel_meters >= OPENING_TRAVEL_TARGET_METERS:
		opening_travel_active = false
		jump_to_event("F0003")


func _refresh_opening_travel_ui() -> void:
	if stage_label != null and current_mode == "travel":
		stage_label.text = "前进 %d / %d 米" % [
			int(round(opening_travel_meters)),
			int(OPENING_TRAVEL_TARGET_METERS),
		]
	if travel_progress_fill != null and travel_progress_back != null:
		var progress: float = clamp(opening_travel_meters / OPENING_TRAVEL_TARGET_METERS, 0.0, 1.0)
		travel_progress_fill.size.x = travel_progress_back.size.x * progress


func _update_battle_turn_flow(delta: float) -> void:
	if current_mode != "battle" or battle_resolved:
		return
	if battle_phase == "enemy_attack":
		if not _battle_animation_active():
			battle_phase = "player"
			battle_action_text = "你的回合：点击出剑"
			_refresh_battle_ui()
		return
	if battle_phase != "enemy":
		return
	if _battle_animation_active():
		return
	battle_enemy_response_elapsed += delta
	if battle_enemy_response_elapsed >= BATTLE_ENEMY_RESPONSE_DELAY:
		_perform_enemy_battle_turn()


func _perform_player_battle_turn() -> void:
	if not battle_active or battle_resolved:
		return
	battle_turns += 1
	enemy_hp = maxi(0, enemy_hp - BATTLE_PLAYER_DAMAGE)
	_start_battle_attack_animation()
	if enemy_hp <= 0:
		battle_phase = "victory"
		battle_resolved = true
		battle_active = false
		battle_action_text = "敌人倒下了"
	else:
		battle_phase = "enemy"
		battle_action_text = "敌人准备反击"
		battle_enemy_response_elapsed = 0.0
	_refresh_battle_ui()


func _perform_enemy_battle_turn() -> void:
	if not battle_active or battle_resolved:
		return
	battle_turns += 1
	hero_hp = maxi(1, hero_hp - BATTLE_ENEMY_DAMAGE)
	_start_enemy_attack_animation()
	battle_phase = "enemy_attack"
	battle_action_text = "敌人正在攻击"
	battle_enemy_response_elapsed = 0.0
	_refresh_battle_ui()


func choose_option(option_index: int) -> void:
	if option_index < 0 or option_index >= available_choice_options.size():
		return
	var option: Dictionary = available_choice_options[option_index]
	var target_id := str(option.get("target", ""))
	var waits_for_replacement := _apply_effects(option.get("effects", {}), target_id)
	if waits_for_replacement:
		return
	if target_id == "EVAL_ENDING":
		_select_ending()
		return
	if target_id.is_empty():
		advance_script()
		return
	_go_to_event(target_id)


func advance_by_pointer() -> void:
	_advance_by_pointer()


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


func unlocked_memory_slots() -> int:
	var inventory: Dictionary = layout.get("inventory", {})
	return int(inventory.get("initial_unlocked_slots", 4))


func inventory_grid_size() -> Vector2i:
	var inventory: Dictionary = layout.get("inventory", {})
	var grid = inventory.get("grid", [7, 4])
	return Vector2i(int(grid[0]), int(grid[1]))


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
			if not memory_id.is_empty():
				memories[memory_id] = item
		elif item.has("id"):
			var event_id := str(item.get("id", ""))
			if ["T", "P", "F", "M", "C", "K", "E"].has(event_id.left(1)):
				events.append(item)
				events_by_id[event_id] = item
				event_index_by_id[event_id] = events.size() - 1
	_validate_loaded_source()


func _validate_loaded_source() -> void:
	for memory_id in REQUIRED_MEMORY_IDS:
		if not memories.has(memory_id):
			validation_errors.append("missing MVP memory from source script: %s" % memory_id)
	for event_id in ["T0001", "T0002", "T0003", "P0034", "F0003", "F0010", "F0036"]:
		if not events_by_id.has(event_id):
			validation_errors.append("missing required MVP event from source script: %s" % event_id)
	_validate_art_assets()


func _validate_art_assets() -> void:
	for path in ART_ASSET_PATHS:
		if not FileAccess.file_exists(path):
			validation_errors.append("missing MVP art asset: %s" % path)
	for memory_id in MEMORY_GRID_SIZES.keys():
		var item_path := str(MEMORY_ITEM_ART_PATHS.get(str(memory_id), ""))
		if item_path.is_empty() or not FileAccess.file_exists(item_path):
			validation_errors.append("missing memory item art asset: %s" % memory_id)


func _build_ui() -> void:
	bg_layer = ColorRect.new()
	bg_layer.color = Color(0.78, 0.84, 0.73)
	bg_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_layer.gui_input.connect(_on_progress_gui_input)
	add_child(bg_layer)

	screen_background_art = _new_texture_rect(ART_GAMEPLAY_SHELL, TextureRect.STRETCH_SCALE)
	screen_background_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_background_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen_background_art)

	memory_icons_texture = _load_texture(ART_MEMORY_ICONS_ATLAS)
	_load_memory_item_textures()
	_load_actor_animation_textures()

	concept_reference = TextureRect.new()
	_set_rect(concept_reference, Rect2(16, 80, 220, 124))
	concept_reference.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	concept_reference.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	concept_reference.modulate = Color(1, 1, 1, 0.26)
	_load_texture_rect(concept_reference, "res://assets/reference/concept_memory_backpack.png")
	add_child(concept_reference)

	stage_panel = _new_panel("stage")
	stage_panel.gui_input.connect(_on_progress_gui_input)
	stage_label = _new_label(22, Color(0.18, 0.14, 0.10))
	add_child(stage_panel)

	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	stage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(stage_label)

	travel_progress_back = ColorRect.new()
	travel_progress_back.color = Color(0.12, 0.10, 0.08, 0.46)
	travel_progress_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(travel_progress_back)

	travel_progress_fill = ColorRect.new()
	travel_progress_fill.color = Color(0.92, 0.62, 0.26, 0.88)
	travel_progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(travel_progress_fill)

	floor_line = ColorRect.new()
	floor_line.color = Color(0.20, 0.17, 0.12, 0.55)
	add_child(floor_line)

	hero_box = _new_panel("hero")
	hero_box.gui_input.connect(_on_progress_gui_input)
	hero_art = _new_texture_rect(ART_HERO, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	hero_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	hero_box.add_child(hero_art)
	add_child(hero_box)

	enemy_box = _new_panel("enemy")
	enemy_box.gui_input.connect(_on_progress_gui_input)
	enemy_art = _new_texture_rect(ART_ENEMY, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	enemy_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	enemy_box.add_child(enemy_art)
	enemy_box_label = _center_label("敌人占位")
	enemy_box_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	enemy_box.add_child(enemy_box_label)
	add_child(enemy_box)

	slash_effect_art = _new_texture_rect(null, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	slash_effect_art.visible = false
	slash_effect_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(slash_effect_art)

	hit_burst_art = _new_texture_rect(null, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	hit_burst_art.visible = false
	hit_burst_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hit_burst_art)

	status_box = ColorRect.new()
	status_box.color = Color(1, 1, 1, 0)
	status_box.gui_input.connect(_on_progress_gui_input)
	status_box_art = _new_texture_rect(ART_BUTTON, TextureRect.STRETCH_SCALE)
	status_box_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	status_box_art.modulate = Color(1, 1, 1, 0.96)
	status_box.add_child(status_box_art)
	status_box_label = _center_label("战斗状态")
	status_box_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_box.add_child(status_box_label)
	add_child(status_box)

	operation_tray = Control.new()
	add_child(operation_tray)

	var tray_bg := _new_panel("operation")
	tray_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	operation_tray.add_child(tray_bg)

	trash_zone = _new_panel("trash")
	trash_zone_icon = _new_texture_rect(_memory_icon_texture("trash"), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	trash_zone_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	trash_zone_icon.modulate = Color(1, 1, 1, 0.78)
	trash_zone.add_child(trash_zone_icon)
	trash_zone_label = _center_label("弃牌堆")
	trash_zone_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trash_zone.add_child(trash_zone_label)
	operation_tray.add_child(trash_zone)

	found_zone = _new_panel("found")
	found_zone.mouse_filter = Control.MOUSE_FILTER_STOP
	found_zone.gui_input.connect(_on_found_zone_gui_input)
	found_zone_icon = _new_texture_rect(_memory_icon_texture("found"), TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	found_zone_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	found_zone_icon.modulate = Color(1, 1, 1, 0.70)
	found_zone.add_child(found_zone_icon)
	found_zone_label = _center_label("新记忆")
	found_zone_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	found_zone.add_child(found_zone_label)
	operation_tray.add_child(found_zone)

	inventory_grid = GridContainer.new()
	inventory_grid.mouse_filter = Control.MOUSE_FILTER_STOP
	inventory_grid.gui_input.connect(_on_inventory_grid_gui_input)
	operation_tray.add_child(inventory_grid)
	_build_inventory_cells()

	inventory_item_layer = Control.new()
	inventory_item_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	operation_tray.add_child(inventory_item_layer)

	dialogue_panel = _new_panel("dialogue")
	dialogue_panel.gui_input.connect(_on_progress_gui_input)
	add_child(dialogue_panel)

	dialogue_panel_art = _new_texture_rect(ART_DIALOGUE_PANEL, TextureRect.STRETCH_SCALE)
	dialogue_panel_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_panel.add_child(dialogue_panel_art)

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

	choice_panel_art = _new_texture_rect(ART_DIALOGUE_PANEL, TextureRect.STRETCH_SCALE)
	choice_panel_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	choice_panel.add_child(choice_panel_art)

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

	source_label = _new_label(16, Color(0.10, 0.10, 0.10, 0.54))
	source_label.text = "REBOOT MVP | 原始 JSONL 剧本 | 概念图风格资源"
	source_label.position = Vector2(20, 18)
	source_label.size = Vector2(760, 28)
	add_child(source_label)

	_build_title_layer()
	_build_bag_detail_layer()
	_build_ending_layer()
	_build_drag_preview()


func _build_title_layer() -> void:
	title_layer = Control.new()
	title_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(title_layer)

	title_background_art = _new_texture_rect(ART_TITLE_BACKGROUND, TextureRect.STRETCH_SCALE)
	title_background_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_layer.add_child(title_background_art)

	title_text_label = _new_label(44, Color(0.16, 0.10, 0.05))
	title_text_label.text = "记忆背包"
	title_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_layer.add_child(title_text_label)

	title_subtitle_label = _new_label(22, Color(0.24, 0.17, 0.10))
	title_subtitle_label.text = "把关系与承诺装进四格背包"
	title_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_layer.add_child(title_subtitle_label)

	title_concept_preview = TextureRect.new()
	title_concept_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	title_concept_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_concept_preview.modulate = Color(1, 1, 1, 0.0)
	_load_texture_rect(title_concept_preview, "res://assets/reference/concept_memory_backpack.png")
	title_layer.add_child(title_concept_preview)

	title_start_button = _new_panel("button")
	title_start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	title_start_button.gui_input.connect(_on_title_start_gui_input)
	_add_button_art(title_start_button)
	title_start_button.add_child(_center_label("开始游戏"))
	title_layer.add_child(title_start_button)

	title_quit_button = _new_panel("button")
	title_quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	title_quit_button.gui_input.connect(_on_title_quit_gui_input)
	_add_button_art(title_quit_button)
	title_quit_button.add_child(_center_label("结束游戏"))
	title_layer.add_child(title_quit_button)

	title_note_panel = _new_panel("note")
	var note := _center_label("")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_note_panel.add_child(note)
	title_layer.add_child(title_note_panel)


func _build_bag_detail_layer() -> void:
	bag_detail_layer = Control.new()
	bag_detail_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bag_detail_layer)

	bag_detail_background_art = _new_texture_rect(ART_GAMEPLAY_SHELL, TextureRect.STRETCH_SCALE)
	bag_detail_background_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	bag_detail_background_art.modulate = Color(1, 1, 1, 0.92)
	bag_detail_layer.add_child(bag_detail_background_art)

	var title := _new_label(32, Color(0.16, 0.10, 0.05))
	title.name = "BagDetailTitle"
	title.text = "记忆背包"
	bag_detail_layer.add_child(title)

	bag_detail_close_button = _new_panel("button")
	bag_detail_close_button.name = "BagDetailClose"
	bag_detail_close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	bag_detail_close_button.gui_input.connect(_on_bag_detail_close_gui_input)
	_add_button_art(bag_detail_close_button)
	bag_detail_close_button.add_child(_center_label("返回"))
	bag_detail_layer.add_child(bag_detail_close_button)

	bag_memory_list = _new_panel("note")
	bag_memory_list.add_child(_center_label("记忆列表\n来自原始脚本的记忆定义"))
	bag_detail_layer.add_child(bag_memory_list)

	bag_detail_panel = _new_panel("dialogue")
	bag_detail_panel.add_child(_center_label("记忆详情\n关系对象 / 承诺 / 丢弃后世界回应"))
	bag_detail_layer.add_child(bag_detail_panel)

	bag_detail_inventory = GridContainer.new()
	bag_detail_layer.add_child(bag_detail_inventory)
	_build_detail_inventory_cells()

	bag_detail_item_layer = Control.new()
	bag_detail_item_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bag_detail_layer.add_child(bag_detail_item_layer)


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
		var icon := _new_texture_rect(null, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = -5
		icon.offset_top = -5
		icon.offset_right = 5
		icon.offset_bottom = 5
		icon.modulate = Color(1, 1, 1, 0.92)
		cell.add_child(icon)
		var label := _center_label(str(index + 1) if index < unlocked else "锁")
		label.add_theme_font_size_override("font_size", 16 if index < unlocked else 13)
		cell.add_child(label)
		bag_detail_cells.append(cell)
		bag_detail_cell_icons.append(icon)
		bag_detail_inventory.add_child(cell)


func _build_ending_layer() -> void:
	ending_layer = Control.new()
	ending_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ending_layer)

	ending_background_art = _new_texture_rect(ART_ENDING_BACKGROUND, TextureRect.STRETCH_SCALE)
	ending_background_art.set_anchors_preset(Control.PRESET_FULL_RECT)
	ending_layer.add_child(ending_background_art)

	var title := _new_label(38, Color(0.16, 0.10, 0.05))
	title.name = "EndingTitle"
	title.text = "MVP 回顾"
	ending_layer.add_child(title)

	ending_summary_panel = _new_panel("dialogue")
	ending_summary_label = _center_label("结局摘要\n名字是否保留\n出发理由是否保留\n世界如何回应")
	ending_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_summary_panel.add_child(ending_summary_label)
	ending_layer.add_child(ending_summary_panel)

	ending_memory_panel = _new_panel("note")
	ending_memory_label = _center_label("最终背包\n保留记忆 / 丢弃记忆 / 核心记忆状态")
	ending_memory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_memory_panel.add_child(ending_memory_label)
	ending_layer.add_child(ending_memory_panel)

	ending_restart_button = _new_panel("button")
	ending_restart_button.name = "EndingRestart"
	ending_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	ending_restart_button.gui_input.connect(_on_ending_restart_gui_input)
	_add_button_art(ending_restart_button)
	ending_restart_button.add_child(_center_label("重新开始"))
	ending_layer.add_child(ending_restart_button)

	ending_title_button = _new_panel("button")
	ending_title_button.name = "EndingTitleButton"
	ending_title_button.mouse_filter = Control.MOUSE_FILTER_STOP
	ending_title_button.gui_input.connect(_on_ending_title_gui_input)
	_add_button_art(ending_title_button)
	ending_title_button.add_child(_center_label("回标题"))
	ending_layer.add_child(ending_title_button)


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
		cell.mouse_filter = Control.MOUSE_FILTER_STOP
		cell.gui_input.connect(_on_inventory_cell_gui_input.bind(index))
		cell.custom_minimum_size = cell_size
		cell.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var icon := _new_texture_rect(null, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = -5
		icon.offset_top = -5
		icon.offset_right = 5
		icon.offset_bottom = 5
		icon.modulate = Color(1, 1, 1, 0.94)
		cell.add_child(icon)
		var label := _center_label(str(index + 1) if index < unlocked else "锁")
		label.add_theme_font_size_override("font_size", 16 if index < unlocked else 13)
		cell.add_child(label)
		inventory_cells.append(cell)
		inventory_cell_labels.append(label)
		inventory_cell_icons.append(icon)
		inventory_grid.add_child(cell)
	_refresh_inventory_ui()


func _build_drag_preview() -> void:
	drag_preview = _new_panel("item_preview")
	drag_preview.visible = false
	drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_preview.modulate = Color(1.0, 1.0, 1.0, 0.86)
	drag_preview_icon = _new_texture_rect(null, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	drag_preview_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	drag_preview.add_child(drag_preview_icon)
	add_child(drag_preview)
	drag_preview.z_index = 100


func _go_to_event(event_id: String) -> void:
	opening_travel_active = false
	var event: Dictionary = events_by_id.get(event_id, {})
	if event.is_empty():
		return
	current_event = event
	current_event_index = int(event_index_by_id.get(event_id, events.find(event)))
	available_choice_options.clear()
	speaker_label.text = str(event.get("speaker", ""))
	text_label.text = str(event.get("text", ""))
	if _apply_event_effects_if_needed(event):
		return
	var event_type := _event_type(event)
	if event_type == "choice":
		available_choice_options = _available_options(event)
		_rebuild_choice_list()
		current_mode = "choice"
	elif event_type == "battle":
		current_mode = "battle"
		_begin_battle(event)
	elif event_type == "ending":
		_reset_battle_state()
		current_mode = "ending"
	elif event_type.begins_with("memory_"):
		_reset_battle_state()
		current_mode = "travel"
	else:
		_reset_battle_state()
		current_mode = "dialogue"
	_apply_mode()


func _reset_script_state() -> void:
	current_event = {}
	current_event_index = 0
	owned_memory_ids.clear()
	memory_grid_positions.clear()
	discarded_memory_ids.clear()
	flags.clear()
	route_id = ""
	selected_ending_id = ""
	applied_event_effect_ids.clear()
	available_choice_options.clear()
	pending_gain_memory_ids.clear()
	pending_resume_event_id = ""
	opening_travel_active = false
	opening_travel_meters = 0.0
	last_story_mode = "dialogue"
	_reset_battle_state()
	_refresh_inventory_ui()


func _event_type(event: Dictionary) -> String:
	return str(event.get("type", ""))


func _begin_battle(event: Dictionary) -> void:
	battle_active = true
	battle_resolved = false
	battle_turns = 0
	battle_enemy_id = str(event.get("enemy_id", "unknown_enemy"))
	battle_reward_ids = _string_array(event.get("reward", []))
	hero_max_hp = BATTLE_HERO_MAX_HP
	hero_hp = hero_max_hp
	enemy_max_hp = _battle_enemy_max_hp(battle_enemy_id)
	enemy_hp = enemy_max_hp
	battle_phase = "player"
	battle_action_text = "你的回合：点击出剑"
	battle_enemy_response_elapsed = 0.0
	_refresh_battle_ui()


func _reset_battle_state() -> void:
	battle_active = false
	battle_resolved = false
	battle_turns = 0
	battle_enemy_id = ""
	battle_reward_ids.clear()
	battle_phase = ""
	battle_action_text = ""
	battle_enemy_response_elapsed = 0.0
	hero_hp = 0
	hero_max_hp = BATTLE_HERO_MAX_HP
	enemy_hp = 0
	enemy_max_hp = BATTLE_ENEMY_MAX_HP
	_stop_battle_attack_animation()


func _refresh_battle_ui() -> void:
	if enemy_box_label != null:
		enemy_box_label.text = ""
		enemy_box_label.add_theme_font_size_override("font_size", 15)
	if stage_label != null and current_mode == "battle":
		stage_label.text = "我方 HP %d/%d    敌人 HP %d/%d" % [
			maxi(hero_hp, 0),
			hero_max_hp,
			maxi(enemy_hp, 0),
			enemy_max_hp,
		]
	if status_box_label != null:
		if battle_resolved:
			status_box_label.text = "胜利\n点击继续"
		elif battle_phase == "enemy":
			status_box_label.text = "敌人回合\n准备反击"
		elif battle_phase == "enemy_attack":
			status_box_label.text = "%s\n请等待" % battle_action_text
		elif not battle_action_text.is_empty():
			status_box_label.text = "%s\n点击攻击" % battle_action_text
		else:
			status_box_label.text = "%s\n点击攻击" % _battle_enemy_label()
		status_box_label.add_theme_font_size_override("font_size", 12)
		return
		if battle_resolved:
			status_box_label.text = "胜利\n点击继续"
		else:
			status_box_label.text = "%s\n点击结算" % _battle_enemy_label()
		status_box_label.add_theme_font_size_override("font_size", 13)


func _next_playable_event_id(start_index: int) -> String:
	for index in range(max(0, start_index), events.size()):
		var event: Dictionary = events[index]
		if _conditions_met(str(event.get("condition", ""))):
			return str(event.get("id", ""))
	return ""


func _apply_event_effects_if_needed(event: Dictionary) -> bool:
	var event_id := str(event.get("id", ""))
	if event_id.is_empty() or applied_event_effect_ids.has(event_id):
		return false
	if event.has("effects"):
		var waits_for_replacement := _apply_effects(event.get("effects", {}))
		applied_event_effect_ids.append(event_id)
		return waits_for_replacement
	return false


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


func _apply_effects(effects_value, resume_event_id := "") -> bool:
	if typeof(effects_value) != TYPE_DICTIONARY:
		return false
	var effects: Dictionary = effects_value
	_discard_memories(_string_array(effects.get("discard", [])))
	_discard_memories(_string_array(effects.get("consume", [])), false)
	_add_flags(_string_array(effects.get("set_flags", [])))
	if effects.has("set_route"):
		route_id = str(effects.get("set_route", ""))
	var gain_ids := _string_array(effects.get("gain", []))
	if _needs_memory_replacement(gain_ids):
		_begin_memory_replace(gain_ids, resume_event_id)
		return true
	_add_memories(gain_ids)
	_refresh_inventory_ui()
	return false


func _add_memories(memory_ids: Array[String]) -> void:
	for memory_id in memory_ids:
		if memory_id.is_empty() or owned_memory_ids.has(memory_id):
			continue
		var placement := _first_available_position(memory_id)
		if placement.x < 0:
			continue
		owned_memory_ids.append(memory_id)
		memory_grid_positions[memory_id] = placement


func _grant_standard_opening_memories() -> void:
	_add_memories([
		"mem_mothers_soup",
		"mem_wooden_sword",
		"mem_reason_to_depart",
		"mem_my_name",
	])


func _discard_memories(memory_ids: Array[String], mark_discarded := true) -> void:
	for memory_id in memory_ids:
		owned_memory_ids.erase(memory_id)
		memory_grid_positions.erase(memory_id)
		if mark_discarded and not discarded_memory_ids.has(memory_id):
			discarded_memory_ids.append(memory_id)
	_refresh_inventory_ui()


func _add_flags(flag_ids: Array[String]) -> void:
	for flag_id in flag_ids:
		if not flag_id.is_empty() and not flags.has(flag_id):
			flags.append(flag_id)


func _needs_memory_replacement(memory_ids: Array[String]) -> bool:
	var simulated_positions := memory_grid_positions.duplicate(true)
	var simulated_owned: Array[String] = []
	for owned_id in owned_memory_ids:
		simulated_owned.append(str(owned_id))
	for memory_id in memory_ids:
		if memory_id.is_empty() or simulated_owned.has(memory_id):
			continue
		var placement := _first_available_position(memory_id, simulated_positions)
		if placement.x < 0:
			return true
		simulated_owned.append(memory_id)
		simulated_positions[memory_id] = placement
	return false


func _begin_memory_replace(memory_ids: Array[String], resume_event_id: String) -> void:
	pending_gain_memory_ids.clear()
	for memory_id in memory_ids:
		if not memory_id.is_empty() and not owned_memory_ids.has(memory_id):
			pending_gain_memory_ids.append(memory_id)
	pending_resume_event_id = resume_event_id
	speaker_label.text = "系统"
	text_label.text = "背包空间不足。拖动一件记忆到弃牌堆，或把新记忆拖到空白区域。"
	current_mode = "memory_replace"
	_refresh_inventory_ui()
	_apply_mode()


func replace_memory_at(slot_index: int, target_grid_position := Vector2i(-1, -1)) -> void:
	if current_mode != "memory_replace":
		return
	if pending_gain_memory_ids.is_empty():
		return
	if slot_index < 0 or slot_index >= owned_memory_ids.size():
		return
	var discarded_id := owned_memory_ids[slot_index]
	var original_position := _memory_grid_position(discarded_id)
	owned_memory_ids.remove_at(slot_index)
	memory_grid_positions.erase(discarded_id)
	if not discarded_memory_ids.has(discarded_id):
		discarded_memory_ids.append(discarded_id)
	var gained_id := str(pending_gain_memory_ids.pop_front())
	if not owned_memory_ids.has(gained_id):
		var placement := target_grid_position
		if placement.x < 0 or not _can_place_memory(gained_id, placement):
			placement = _first_available_position(gained_id)
		if placement.x < 0:
			owned_memory_ids.insert(slot_index, discarded_id)
			memory_grid_positions[discarded_id] = original_position
			discarded_memory_ids.erase(discarded_id)
			pending_gain_memory_ids.push_front(gained_id)
			_refresh_inventory_ui()
			return
		owned_memory_ids.append(gained_id)
		memory_grid_positions[gained_id] = placement
	_refresh_inventory_ui()
	if not pending_gain_memory_ids.is_empty():
		return
	var resume_event_id := pending_resume_event_id
	pending_resume_event_id = ""
	if resume_event_id == "EVAL_ENDING":
		_select_ending()
	elif not resume_event_id.is_empty():
		_go_to_event(resume_event_id)
	else:
		advance_script()


func move_memory_to(memory_id: String, target_grid_position: Vector2i) -> bool:
	if not owned_memory_ids.has(memory_id):
		return false
	if not _can_place_memory(memory_id, target_grid_position, memory_id):
		return false
	memory_grid_positions[memory_id] = target_grid_position
	_refresh_inventory_ui()
	return true


func accept_pending_memory_at(target_grid_position: Vector2i) -> bool:
	if current_mode != "memory_replace" or pending_gain_memory_ids.is_empty():
		return false
	var pending_id := str(pending_gain_memory_ids[0])
	if not _can_place_memory(pending_id, target_grid_position):
		return false
	pending_gain_memory_ids.pop_front()
	if not owned_memory_ids.has(pending_id):
		owned_memory_ids.append(pending_id)
		memory_grid_positions[pending_id] = target_grid_position
	_refresh_inventory_ui()
	if pending_gain_memory_ids.is_empty():
		_resume_after_memory_replace()
	return true


func _resume_after_memory_replace() -> void:
	var resume_event_id := pending_resume_event_id
	pending_resume_event_id = ""
	if resume_event_id == "EVAL_ENDING":
		_select_ending()
	elif not resume_event_id.is_empty():
		_go_to_event(resume_event_id)
	else:
		advance_script()


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
	_update_screen_background()
	stage_panel.visible = current_mode == "travel" or current_mode == "battle" or current_mode == "memory_replace"
	stage_label.visible = stage_panel.visible
	travel_progress_back.visible = current_mode == "travel" and opening_travel_active
	travel_progress_fill.visible = current_mode == "travel" and opening_travel_active
	floor_line.visible = stage_panel.visible
	hero_box.visible = current_mode == "travel" or current_mode == "battle" or current_mode == "memory_replace"
	enemy_box.visible = current_mode == "battle"
	status_box.visible = current_mode == "battle"
	operation_tray.visible = current_mode == "travel" or current_mode == "battle" or current_mode == "memory_replace"
	dialogue_panel.visible = current_mode == "dialogue" or current_mode == "memory_replace"
	choice_panel.visible = current_mode == "choice"
	title_layer.visible = current_mode == "title"
	bag_detail_layer.visible = current_mode == "bag_detail"
	ending_layer.visible = current_mode == "ending"
	concept_reference.visible = false
	source_label.visible = false
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
	elif current_mode == "memory_replace":
		_apply_memory_replace_layout()
	elif current_mode == "travel":
		_apply_travel_layout()
	else:
		_apply_dialogue_layout()


func _update_screen_background() -> void:
	if screen_background_art == null:
		return
	match current_mode:
		"title", "ending":
			screen_background_art.visible = false
		_:
			screen_background_art.visible = true


func _apply_dialogue_layout() -> void:
	_set_rect(dialogue_panel, _screen_rect("dialogue", "dialogue_panel"))
	_set_rect(concept_reference, Rect2(16, 80, 220, 124))


func _apply_choice_layout() -> void:
	_set_rect(dialogue_panel, _screen_rect("dialogue", "dialogue_panel"))
	_set_rect(choice_panel, _screen_rect("choice", "choice_panel"))


func _apply_memory_replace_layout() -> void:
	_apply_travel_layout()
	stage_label.text = "背包替换：新记忆必须落入已解锁格子"
	_set_rect(dialogue_panel, Rect2(176, 110, 900, 64))


func _handle_progress_mouse_event(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_start_pointer_hold()
	else:
		_stop_pointer_hold()
	get_viewport().set_input_as_handled()


func _on_progress_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_handle_progress_mouse_event(event as InputEventMouseButton)


func _on_found_zone_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed and current_mode == "memory_replace":
			_start_drag("pending", -1, _pending_memory_id(), mouse_event.global_position)
			get_viewport().set_input_as_handled()


func _on_inventory_grid_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed and current_mode in ["travel", "battle"]:
			open_bag_detail()
			get_viewport().set_input_as_handled()


func _on_title_start_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_script()
		get_viewport().set_input_as_handled()


func _on_title_quit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		get_tree().quit()


func _on_bag_detail_close_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return_to_story()
		get_viewport().set_input_as_handled()


func _on_ending_restart_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_script()
		get_viewport().set_input_as_handled()


func _on_ending_title_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_reset_script_state()
		show_mode("title")
		get_viewport().set_input_as_handled()


func _on_inventory_cell_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if current_mode in ["travel", "battle", "memory_replace"]:
				var memory_id := _memory_id_at_slot(slot_index)
				if not memory_id.is_empty():
					_start_drag("owned", owned_memory_ids.find(memory_id), memory_id, mouse_event.global_position)
				get_viewport().set_input_as_handled()
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			if drag_active:
				_finish_drag(mouse_event.global_position)
			get_viewport().set_input_as_handled()


func _start_pointer_hold() -> void:
	if not _can_pointer_advance():
		return
	_advance_by_pointer()
	pointer_hold_active = true
	pointer_hold_elapsed = 0.0
	pointer_hold_next_at = POINTER_HOLD_INITIAL_DELAY


func _stop_pointer_hold() -> void:
	pointer_hold_active = false
	pointer_hold_elapsed = 0.0
	pointer_hold_next_at = 0.0


func _can_pointer_advance() -> bool:
	if opening_travel_active:
		return false
	return current_mode in ["title", "dialogue", "travel", "battle", "ending"]


func _advance_by_pointer() -> void:
	if opening_travel_active:
		return
	if current_mode == "title":
		start_script()
	elif current_mode == "battle":
		advance_battle()
	elif current_mode in ["dialogue", "travel", "ending"]:
		advance_script()


func _start_drag(source_kind: String, source_slot: int, memory_id: String, pointer_position: Vector2) -> void:
	if memory_id.is_empty():
		return
	drag_active = true
	drag_moved = false
	drag_source_kind = source_kind
	drag_source_slot = source_slot
	drag_memory_id = memory_id
	drag_origin_position = _memory_grid_position(memory_id)
	drag_start_position = pointer_position
	_update_drag_preview(_memory_name(memory_id))
	_update_drag_preview_position(pointer_position)
	drag_preview.visible = true
	_update_inventory_drag_visuals(source_slot)


func _finish_drag(pointer_position: Vector2) -> void:
	if not drag_active:
		return
	var handled := false
	var target_position := _grid_position_at_point(pointer_position)
	if current_mode == "memory_replace":
		if drag_source_kind == "pending" and target_position.x >= 0:
			handled = accept_pending_memory_at(target_position)
		elif drag_source_kind == "owned" and _drop_hits_trash(pointer_position):
			var pending_target := target_position if target_position.x >= 0 else drag_origin_position
			replace_memory_at(drag_source_slot, pending_target)
			handled = true
		elif drag_source_kind == "owned" and target_position.x >= 0:
			handled = move_memory_to(drag_memory_id, target_position)
	elif drag_source_kind == "owned" and target_position.x >= 0:
		handled = move_memory_to(drag_memory_id, target_position)
	if not handled and drag_source_kind == "owned" and drag_origin_position.x >= 0:
		memory_grid_positions[drag_memory_id] = drag_origin_position
		_refresh_inventory_ui()
	_clear_drag_state()


func _clear_drag_state() -> void:
	drag_active = false
	drag_moved = false
	drag_source_kind = ""
	drag_source_slot = -1
	drag_memory_id = ""
	drag_origin_position = Vector2i(-1, -1)
	if drag_preview != null:
		drag_preview.visible = false
	_update_inventory_drag_visuals(-1)


func _replacement_slot_from_drag(pointer_position: Vector2) -> int:
	if drag_source_kind == "owned" and _can_replace_slot(drag_source_slot):
		return drag_source_slot
	var slot := _slot_at_position(pointer_position)
	if _can_replace_slot(slot):
		return slot
	return -1


func _can_replace_slot(slot_index: int) -> bool:
	return current_mode == "memory_replace" and slot_index >= 0 and slot_index < owned_memory_ids.size()


func _pending_memory_id() -> String:
	return str(pending_gain_memory_ids[0]) if not pending_gain_memory_ids.is_empty() else ""


func _drop_hits_trash(pointer_position: Vector2) -> bool:
	return trash_zone.visible and trash_zone.get_global_rect().has_point(pointer_position)


func _drop_hits_inventory(pointer_position: Vector2) -> bool:
	return inventory_grid.visible and inventory_grid.get_global_rect().has_point(pointer_position)


func _slot_at_position(pointer_position: Vector2) -> int:
	for index in range(inventory_cells.size()):
		if inventory_cells[index].get_global_rect().has_point(pointer_position):
			return index
	return -1


func _memory_id_at_slot(slot_index: int) -> String:
	var grid_position := _grid_position_from_slot(slot_index)
	for memory_id in owned_memory_ids:
		if _memory_rect(str(memory_id)).has_point(grid_position):
			return str(memory_id)
	return ""


func _grid_position_from_slot(slot_index: int) -> Vector2i:
	var grid_size := inventory_grid_size()
	if slot_index < 0 or grid_size.x <= 0:
		return Vector2i(-1, -1)
	return Vector2i(slot_index % grid_size.x, int(floor(float(slot_index) / float(grid_size.x))))


func _grid_position_at_point(pointer_position: Vector2) -> Vector2i:
	var slot := _slot_at_position(pointer_position)
	return _grid_position_from_slot(slot)


func _memory_grid_position(memory_id: String) -> Vector2i:
	if memory_grid_positions.has(memory_id):
		return memory_grid_positions[memory_id]
	return Vector2i(-1, -1)


func _memory_grid_size(memory_id: String) -> Vector2i:
	return MEMORY_GRID_SIZES.get(memory_id, Vector2i(1, 1))


func _memory_rect(memory_id: String, position := Vector2i(-1, -1)) -> Rect2i:
	var origin := position if position.x >= 0 else _memory_grid_position(memory_id)
	return Rect2i(origin, _memory_grid_size(memory_id))


func _can_place_memory(memory_id: String, position: Vector2i, ignore_memory_id := "", positions := {}) -> bool:
	if position.x < 0 or position.y < 0:
		return false
	var grid_size := inventory_grid_size()
	var size := _memory_grid_size(memory_id)
	if position.x + size.x > grid_size.x or position.y + size.y > grid_size.y:
		return false
	var candidate := Rect2i(position, size)
	var occupied_positions: Dictionary = positions if not positions.is_empty() else memory_grid_positions
	for other_id in occupied_positions.keys():
		var typed_id := str(other_id)
		if typed_id == ignore_memory_id:
			continue
		if not occupied_positions.has(typed_id):
			continue
		if _rects_overlap(candidate, _memory_rect(typed_id, occupied_positions[typed_id])):
			return false
	return true


func _rects_overlap(a: Rect2i, b: Rect2i) -> bool:
	return a.position.x < b.end.x and a.end.x > b.position.x and a.position.y < b.end.y and a.end.y > b.position.y


func _first_available_position(memory_id: String, positions_override := {}) -> Vector2i:
	var occupied_positions: Dictionary = positions_override if not positions_override.is_empty() else memory_grid_positions
	var grid_size := inventory_grid_size()
	var item_size := _memory_grid_size(memory_id)
	var preferred_position: Vector2i = MEMORY_DEFAULT_POSITIONS.get(memory_id, Vector2i(-1, -1))
	if preferred_position.x >= 0 and _can_place_memory(memory_id, preferred_position, "", occupied_positions):
		return preferred_position
	for y in range(0, grid_size.y - item_size.y + 1):
		for x in range(0, grid_size.x - item_size.x + 1):
			var candidate := Vector2i(x, y)
			if _can_place_memory(memory_id, candidate, "", occupied_positions):
				return candidate
	return Vector2i(-1, -1)


func _update_drag_preview(label_text: String) -> void:
	var preview_rect := _inventory_item_rect(inventory_grid.size, Vector2i.ZERO, _memory_grid_size(drag_memory_id))
	drag_preview.size = preview_rect.size
	if drag_preview_icon != null:
		drag_preview_icon.texture = _memory_item_texture(drag_memory_id)
		drag_preview_icon.visible = true
		drag_preview_icon.stretch_mode = TextureRect.STRETCH_SCALE
	drag_preview.tooltip_text = label_text


func _update_drag_preview_position(pointer_position: Vector2) -> void:
	if drag_preview == null:
		return
	drag_preview.position = pointer_position + Vector2(14, 14)


func _update_inventory_drag_visuals(active_slot: int) -> void:
	for index in range(inventory_cells.size()):
		var slot_position := _grid_position_from_slot(index)
		var active := false
		if active_slot >= 0 and not drag_memory_id.is_empty():
			active = _memory_rect(drag_memory_id).has_point(slot_position)
		inventory_cells[index].modulate = Color(1, 1, 1, 0.48) if active else Color(1, 1, 1, 1)


func _string_array(value) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) == TYPE_ARRAY:
		for item in value:
			result.append(str(item))
	elif typeof(value) == TYPE_STRING and not str(value).is_empty():
		result.append(str(value))
	return result


func _refresh_inventory_ui() -> void:
	for index in range(inventory_cell_labels.size()):
		var label := inventory_cell_labels[index]
		var icon: TextureRect = inventory_cell_icons[index] if index < inventory_cell_icons.size() else null
		label.text = ""
		if icon != null:
			icon.texture = null
			icon.visible = false
	_rebuild_memory_item_layer(inventory_item_layer)
	_refresh_detail_inventory_ui()
	if found_zone_label != null:
		if pending_gain_memory_ids.is_empty():
			found_zone_label.text = "新记忆"
			if found_zone_icon != null:
				found_zone_icon.texture = _memory_icon_texture("found")
				found_zone_icon.visible = true
		else:
			var pending_memory_id := str(pending_gain_memory_ids[0])
			found_zone_label.text = "待放入\n%s" % _short_memory_name(pending_memory_id)
			if found_zone_icon != null:
				found_zone_icon.texture = _memory_icon_texture(pending_memory_id)
				found_zone_icon.visible = true
	if trash_zone_label != null:
		if discarded_memory_ids.is_empty():
			trash_zone_label.text = "弃牌堆"
			if trash_zone_icon != null:
				trash_zone_icon.texture = _memory_icon_texture("trash")
				trash_zone_icon.visible = true
		else:
			var discarded_memory_id := str(discarded_memory_ids[discarded_memory_ids.size() - 1])
			trash_zone_label.text = "最近丢弃\n%s" % _short_memory_name(discarded_memory_id)
			if trash_zone_icon != null:
				trash_zone_icon.texture = _memory_icon_texture(discarded_memory_id)
				trash_zone_icon.visible = true


func _refresh_detail_inventory_ui() -> void:
	for index in range(bag_detail_cells.size()):
		var label := bag_detail_cells[index].get_child(bag_detail_cells[index].get_child_count() - 1) as Label
		var icon: TextureRect = bag_detail_cell_icons[index] if index < bag_detail_cell_icons.size() else null
		label.text = ""
		if icon != null:
			icon.texture = null
			icon.visible = false
	_rebuild_memory_item_layer(bag_detail_item_layer)


func _rebuild_memory_item_layer(item_layer: Control) -> void:
	if item_layer == null:
		return
	for child in item_layer.get_children():
		child.queue_free()
	for memory_id in owned_memory_ids:
		var typed_id := str(memory_id)
		var position := _memory_grid_position(typed_id)
		if position.x < 0:
			continue
		var item_rect := _memory_item_visual_rect(item_layer.size, position, _memory_grid_size(typed_id))
		var item := Control.new()
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		item.position = item_rect.position
		item.size = item_rect.size
		var icon := _new_texture_rect(_memory_item_texture(typed_id), TextureRect.STRETCH_SCALE)
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.modulate = Color(1, 1, 1, 1)
		item.add_child(icon)
		item.tooltip_text = _memory_name(typed_id)
		item_layer.add_child(item)


func _memory_name(memory_id: String) -> String:
	var memory: Dictionary = memories.get(memory_id, {})
	return str(memory.get("name", memory_id))


func _short_memory_name(memory_id: String) -> String:
	var memory_name := _memory_name(memory_id)
	if memory_name.length() <= 5:
		return memory_name
	return memory_name.substr(0, 5)


func _refresh_ending_ui() -> void:
	var title := ending_layer.get_node("EndingTitle") as Label
	if title != null:
		if selected_ending_id.is_empty():
			title.text = "MVP 回顾灰盒"
		else:
			title.text = "结局：%s" % _format_ending_name(selected_ending_id)
	if ending_summary_label != null:
		ending_summary_label.add_theme_font_size_override("font_size", 18)
		ending_summary_label.text = _ending_summary_text()
	if ending_memory_label != null:
		ending_memory_label.add_theme_font_size_override("font_size", 16)
		ending_memory_label.text = _ending_memory_text()


func _ending_summary_text() -> String:
	var source_text := ""
	if not current_event.is_empty() and _event_type(current_event) == "ending":
		source_text = str(current_event.get("text", ""))
	elif not selected_ending_id.is_empty():
		var ending_event := _ending_event_for_selected()
		source_text = str(ending_event.get("text", ""))
	if source_text.is_empty():
		source_text = "尚未进入原脚本结局。"
	return "%s\n\n路线：%s\n原脚本结局：%s\n出发理由：%s\n我的名字：%s" % [
		source_text,
		route_id if not route_id.is_empty() else "未选择",
		selected_ending_id if not selected_ending_id.is_empty() else "未判定",
		"保留" if has_memory("mem_reason_to_depart") else "丢失",
		"保留" if has_memory("mem_my_name") else "丢失",
	]


func _ending_memory_text() -> String:
	return "最终背包\n%s\n\n已丢弃\n%s\n\n温柔记忆分数：%d" % [
		_memory_names_for_ids(owned_memory_ids),
		_memory_names_for_ids(discarded_memory_ids),
		_memory_tag_score("温柔"),
	]


func _ending_event_for_selected() -> Dictionary:
	if selected_ending_id.is_empty():
		return {}
	var required_condition := "ending:%s" % selected_ending_id
	for event in events:
		if _event_type(event) == "ending" and str(event.get("condition", "")) == required_condition:
			return event
	return {}


func _memory_names_for_ids(memory_ids: Array[String]) -> String:
	if memory_ids.is_empty():
		return "无"
	var names: Array[String] = []
	for memory_id in memory_ids:
		names.append(_memory_name(memory_id))
	return "\n".join(names)


func _format_ending_name(ending_id: String) -> String:
	match ending_id:
		"hero":
			return "英雄"
		"hollow":
			return "空壳"
		"homecoming":
			return "归乡"
		"nameless":
			return "无名"
		"reconciliation":
			return "和解"
		_:
			return ending_id


func _format_enemy_name(enemy_id: String) -> String:
	return enemy_id.replace("enemy_", "").replace("boss_", "").replace("_", " / ")


func _battle_enemy_label() -> String:
	if battle_enemy_id.begins_with("boss_"):
		return "Boss"
	return "敌群"


func _battle_enemy_max_hp(enemy_id: String) -> int:
	if enemy_id.begins_with("boss_"):
		return BATTLE_BOSS_MAX_HP
	if enemy_id.find(",") >= 0:
		return BATTLE_ENEMY_MAX_HP + 8
	return BATTLE_ENEMY_MAX_HP


func _format_rewards(reward_ids: Array[String]) -> String:
	if reward_ids.is_empty():
		return "无奖励"
	var labels: Array[String] = []
	for reward_id in reward_ids:
		labels.append(reward_id.replace("_", " "))
	return ", ".join(labels)


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
	_set_rect(bag_detail_item_layer, _screen_rect("bag_detail", "inventory_board"))
	_refresh_detail_inventory_ui()


func _apply_ending_layout() -> void:
	_set_rect(ending_layer.get_node("EndingTitle"), _screen_rect("ending", "title"))
	_set_rect(ending_summary_panel, _screen_rect("ending", "summary_panel"))
	_set_rect(ending_memory_panel, _screen_rect("ending", "memory_panel"))
	_set_rect(ending_layer.get_node("EndingRestart"), _screen_rect("ending", "restart_button"))
	_set_rect(ending_layer.get_node("EndingTitleButton"), _screen_rect("ending", "title_button"))
	_refresh_ending_ui()


func _apply_travel_layout() -> void:
	_set_rect(stage_panel, _screen_rect("travel", "stage"))
	_set_rect(stage_label, Rect2(_screen_rect("travel", "stage").position + Vector2(26, 16), Vector2(620, 34)))
	var progress_rect := Rect2(_screen_rect("travel", "stage").position + Vector2(26, 58), Vector2(360, 10))
	_set_rect(travel_progress_back, progress_rect)
	_set_rect(travel_progress_fill, Rect2(progress_rect.position, Vector2(0, progress_rect.size.y)))
	_set_rect(floor_line, _screen_rect("travel", "floor_baseline"))
	hero_base_rect = _grounded_actor_rect(_screen_rect("travel", "hero"), _screen_rect("travel", "floor_baseline"), 188.0)
	_set_rect(hero_box, hero_base_rect)
	_set_operation_layout("travel")
	if opening_travel_active:
		_refresh_opening_travel_ui()
	else:
		stage_label.text = ""


func _apply_battle_layout() -> void:
	_set_rect(stage_panel, _screen_rect("battle", "stage"))
	_set_rect(stage_label, Rect2(_screen_rect("battle", "stage").position + Vector2(26, 16), Vector2(620, 34)))
	travel_progress_back.visible = false
	travel_progress_fill.visible = false
	_set_rect(floor_line, _screen_rect("battle", "floor_baseline"))
	hero_base_rect = _grounded_actor_rect(_screen_rect("battle", "hero"), _screen_rect("battle", "floor_baseline"), 188.0)
	enemy_base_rect = _grounded_actor_rect(_screen_rect("battle", "enemy"), _screen_rect("battle", "floor_baseline"), 190.0)
	_set_rect(hero_box, hero_base_rect)
	_set_rect(enemy_box, enemy_base_rect)
	_set_rect(status_box, _screen_rect("battle", "status"))
	_set_operation_layout("battle")
	_refresh_battle_ui()


func _set_operation_layout(screen_id: String) -> void:
	var tray_rect := _screen_rect(screen_id, "operation_tray")
	_set_rect(operation_tray, tray_rect)
	_set_rect(trash_zone, _relative_rect(_screen_rect(screen_id, "trash_zone"), tray_rect.position))
	_set_rect(found_zone, _relative_rect(_screen_rect(screen_id, "found_zone"), tray_rect.position))
	var inventory_rect := _relative_rect(_screen_rect(screen_id, "inventory_board"), tray_rect.position)
	_set_rect(inventory_grid, inventory_rect)
	_set_rect(inventory_item_layer, inventory_rect)
	_refresh_inventory_ui()


func _screen_rect(screen_id: String, section_id: String) -> Rect2:
	var screens: Dictionary = layout.get("screens", {})
	var screen: Dictionary = screens.get(screen_id, {})
	return _rect_from_array(screen.get(section_id, [0, 0, 0, 0]))


func _relative_rect(rect: Rect2, origin: Vector2) -> Rect2:
	return Rect2(rect.position - origin, rect.size)


func _grounded_actor_rect(anchor_rect: Rect2, floor_rect: Rect2, actor_height: float) -> Rect2:
	var width: float = max(anchor_rect.size.x, actor_height * 0.62)
	var bottom: float = floor_rect.position.y + 18.0
	return Rect2(Vector2(anchor_rect.get_center().x - width * 0.5, bottom - actor_height), Vector2(width, actor_height))


func _update_actor_animations(delta: float) -> void:
	if hero_art == null or enemy_art == null or hero_box == null or enemy_box == null:
		return
	hero_animation_elapsed += delta
	enemy_animation_elapsed += delta
	if hero_attack_active:
		_update_hero_attack_animation(delta)
	elif hero_hit_active:
		_update_hero_hit_animation(delta)
	elif current_mode == "travel" or current_mode == "memory_replace":
		hero_art.texture = _frame_texture(hero_walk_frames, _loop_frame(hero_animation_elapsed, WALK_FRAME_TIME, HERO_WALK_FRAMES), hero_static_texture)
		hero_box.position = hero_base_rect.position + Vector2(0, sin(hero_animation_elapsed * TAU * 2.0) * 3.0)
	elif current_mode == "battle":
		hero_art.texture = hero_static_texture
		hero_box.position = hero_base_rect.position
	else:
		hero_art.texture = hero_static_texture
		hero_box.position = hero_base_rect.position
	if current_mode == "battle":
		if enemy_hit_active:
			_update_enemy_hit_animation(delta)
		elif enemy_attack_active:
			_update_enemy_attack_animation(delta)
		else:
			enemy_art.texture = _frame_texture(enemy_idle_frames, _loop_frame(enemy_animation_elapsed, ENEMY_IDLE_FRAME_TIME, ACTOR_LOOP_FRAMES), enemy_static_texture)
			enemy_box.position = enemy_base_rect.position + Vector2(sin(enemy_animation_elapsed * TAU * 1.6) * 3.0, sin(enemy_animation_elapsed * TAU * 1.1) * 2.0)
	else:
		enemy_art.texture = enemy_static_texture
		enemy_box.position = enemy_base_rect.position
	if slash_active:
		_update_slash_animation(delta)
	if hit_burst_active:
		_update_hit_burst_animation(delta)
	_update_battle_impact_feedback()


func _update_hero_attack_animation(delta: float) -> void:
	hero_attack_elapsed += delta
	var frame := mini(HERO_ATTACK_FRAMES - 1, int(floor(hero_attack_elapsed / ATTACK_FRAME_TIME)))
	hero_art.texture = _frame_texture(hero_attack_frames, frame, hero_static_texture)
	var progress: float = clamp(hero_attack_elapsed / (ATTACK_FRAME_TIME * float(HERO_ATTACK_FRAMES - 1)), 0.0, 1.0)
	var lunge: float = sin(progress * PI) * 95.0
	hero_box.position = hero_base_rect.position + Vector2(lunge, -sin(progress * PI * 2.0) * 6.0)
	if frame >= HERO_ATTACK_FRAMES - 1:
		hero_attack_active = false
		hero_attack_elapsed = 0.0
		hero_box.position = hero_base_rect.position


func _update_hero_hit_animation(delta: float) -> void:
	hero_hit_elapsed += delta
	hero_art.texture = hero_static_texture
	var shake := Vector2(sin(hero_hit_elapsed * 74.0) * 7.0, sin(hero_hit_elapsed * 51.0) * 4.0)
	hero_box.position = hero_base_rect.position + shake
	var progress: float = clamp(hero_hit_elapsed / BATTLE_HERO_HIT_DURATION, 0.0, 1.0)
	hero_art.modulate = Color(1.0, 0.48 + 0.52 * progress, 0.42 + 0.58 * progress, 1.0)
	if progress >= 1.0:
		hero_hit_active = false
		hero_hit_elapsed = 0.0
		hero_box.position = hero_base_rect.position
		hero_art.modulate = Color.WHITE


func _update_enemy_hit_animation(delta: float) -> void:
	enemy_hit_elapsed += delta
	var frame := mini(ENEMY_HIT_FRAMES - 1, int(floor(enemy_hit_elapsed / ENEMY_HIT_FRAME_TIME)))
	enemy_art.texture = _frame_texture(enemy_hit_frames, frame, enemy_static_texture)
	var shake := Vector2(sin(enemy_hit_elapsed * 68.0) * 9.0, sin(enemy_hit_elapsed * 43.0) * 4.0)
	enemy_box.position = enemy_base_rect.position + shake
	var flash_strength: float = clamp(1.0 - enemy_hit_elapsed / (ENEMY_HIT_FRAME_TIME * float(ENEMY_HIT_FRAMES)), 0.0, 1.0)
	enemy_art.modulate = Color(1.0, 0.46 + 0.38 * (1.0 - flash_strength), 0.38 + 0.52 * (1.0 - flash_strength), 1.0)
	if frame >= ENEMY_HIT_FRAMES - 1:
		enemy_hit_active = false
		enemy_hit_elapsed = 0.0
		enemy_box.position = enemy_base_rect.position
		enemy_art.modulate = Color.WHITE


func _update_enemy_attack_animation(delta: float) -> void:
	enemy_attack_elapsed += delta
	enemy_art.texture = _frame_texture(enemy_idle_frames, _loop_frame(enemy_animation_elapsed, ENEMY_IDLE_FRAME_TIME, ACTOR_LOOP_FRAMES), enemy_static_texture)
	var progress: float = clamp(enemy_attack_elapsed / BATTLE_ENEMY_ATTACK_DURATION, 0.0, 1.0)
	var lunge: float = sin(progress * PI) * -82.0
	enemy_box.position = enemy_base_rect.position + Vector2(lunge, -sin(progress * PI * 2.0) * 5.0)
	if progress >= 1.0:
		enemy_attack_active = false
		enemy_attack_elapsed = 0.0
		enemy_box.position = enemy_base_rect.position


func _update_slash_animation(delta: float) -> void:
	slash_elapsed += delta
	var frame := mini(SLASH_FRAMES - 1, int(floor(slash_elapsed / SLASH_FRAME_TIME)))
	slash_effect_art.texture = _frame_texture(slash_effect_frames, frame, null)
	var slash_rect := Rect2(enemy_base_rect.position + Vector2(-44, 8), Vector2(218, 136))
	_set_rect(slash_effect_art, slash_rect)
	slash_effect_art.visible = true
	slash_effect_art.modulate = Color(1, 1, 1, clamp(1.0 - slash_elapsed / (SLASH_FRAME_TIME * float(SLASH_FRAMES)), 0.0, 1.0))
	if frame >= SLASH_FRAMES - 1:
		slash_active = false
		slash_elapsed = 0.0
		slash_effect_art.visible = false
		slash_effect_art.modulate = Color.WHITE


func _update_hit_burst_animation(delta: float) -> void:
	hit_burst_elapsed += delta
	var frame := mini(HIT_BURST_FRAMES - 1, int(floor(hit_burst_elapsed / HIT_BURST_FRAME_TIME)))
	hit_burst_art.texture = _frame_texture(hit_burst_frames, frame, null)
	var progress: float = clamp(hit_burst_elapsed / (HIT_BURST_FRAME_TIME * float(HIT_BURST_FRAMES)), 0.0, 1.0)
	var burst_size := Vector2(178.0 + progress * 64.0, 178.0 + progress * 64.0)
	var burst_center := enemy_base_rect.get_center() + Vector2(-18.0, -24.0)
	if hit_burst_target == "hero":
		burst_center = hero_base_rect.get_center() + Vector2(10.0, -20.0)
	_set_rect(hit_burst_art, Rect2(burst_center - burst_size * 0.5, burst_size))
	hit_burst_art.visible = true
	hit_burst_art.modulate = Color(1, 1, 1, clamp(1.0 - progress * 0.78, 0.0, 1.0))
	if frame >= HIT_BURST_FRAMES - 1:
		hit_burst_active = false
		hit_burst_elapsed = 0.0
		hit_burst_art.visible = false
		hit_burst_art.modulate = Color.WHITE


func _update_battle_impact_feedback() -> void:
	var offset := Vector2.ZERO
	if current_mode == "battle" and _battle_animation_active():
		var impact_elapsed: float = max(max(enemy_hit_elapsed, slash_elapsed), max(hero_hit_elapsed, enemy_attack_elapsed))
		var impact_duration: float = max(max(SLASH_FRAME_TIME * float(SLASH_FRAMES), HIT_BURST_FRAME_TIME * float(HIT_BURST_FRAMES)), BATTLE_ENEMY_ATTACK_DURATION)
		var strength: float = clamp(1.0 - impact_elapsed / impact_duration, 0.0, 1.0)
		offset = Vector2(sin(impact_elapsed * 92.0) * 5.0, sin(impact_elapsed * 71.0) * 3.0) * strength
	if current_mode == "battle":
		stage_panel.position = _screen_rect("battle", "stage").position + offset
		floor_line.position = _screen_rect("battle", "floor_baseline").position + offset
		hero_box.position += offset
		enemy_box.position += offset
		if slash_effect_art != null and slash_effect_art.visible:
			slash_effect_art.position += offset
		if hit_burst_art != null and hit_burst_art.visible:
			hit_burst_art.position += offset
	elif current_mode == "travel":
		stage_panel.position = _screen_rect("travel", "stage").position
		floor_line.position = _screen_rect("travel", "floor_baseline").position


func _start_battle_attack_animation() -> void:
	if current_mode != "battle":
		return
	hero_attack_active = true
	enemy_hit_active = true
	slash_active = true
	hit_burst_active = true
	hit_burst_target = "enemy"
	hero_attack_elapsed = 0.0
	enemy_hit_elapsed = 0.0
	slash_elapsed = 0.0
	hit_burst_elapsed = 0.0
	if slash_effect_art != null:
		slash_effect_art.visible = true
	if hit_burst_art != null:
		hit_burst_art.visible = true


func _start_enemy_attack_animation() -> void:
	if current_mode != "battle":
		return
	enemy_attack_active = true
	hero_hit_active = true
	hit_burst_active = true
	hit_burst_target = "hero"
	enemy_attack_elapsed = 0.0
	hero_hit_elapsed = 0.0
	hit_burst_elapsed = 0.0
	if hit_burst_art != null:
		hit_burst_art.visible = true


func _stop_battle_attack_animation() -> void:
	hero_attack_active = false
	enemy_hit_active = false
	enemy_attack_active = false
	hero_hit_active = false
	slash_active = false
	hit_burst_active = false
	hit_burst_target = "enemy"
	hero_attack_elapsed = 0.0
	enemy_hit_elapsed = 0.0
	enemy_attack_elapsed = 0.0
	hero_hit_elapsed = 0.0
	slash_elapsed = 0.0
	hit_burst_elapsed = 0.0
	if slash_effect_art != null:
		slash_effect_art.visible = false
	if hit_burst_art != null:
		hit_burst_art.visible = false
	if enemy_art != null:
		enemy_art.modulate = Color.WHITE
	if hero_art != null:
		hero_art.modulate = Color.WHITE


func _battle_animation_active() -> bool:
	return hero_attack_active or enemy_hit_active or enemy_attack_active or hero_hit_active or slash_active or hit_burst_active


func _loop_frame(elapsed: float, frame_time: float, frame_count: int) -> int:
	if frame_count <= 0 or frame_time <= 0.0:
		return 0
	return int(floor(elapsed / frame_time)) % frame_count


func _frame_texture(frames: Array[Texture2D], frame_index: int, fallback: Texture2D = null) -> Texture2D:
	if frames.is_empty():
		return fallback
	var safe_index := mini(maxi(frame_index, 0), frames.size() - 1)
	return frames[safe_index]


func _build_sheet_frames(sheet: Texture2D, frame_size: Vector2i, frame_count: int, sheet_columns := 0) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	if sheet == null or frame_size.x <= 0 or frame_size.y <= 0 or frame_count <= 0:
		return frames
	var columns := sheet_columns
	if columns <= 0:
		columns = int(floor(float(sheet.get_width()) / float(frame_size.x)))
	var rows := int(floor(float(sheet.get_height()) / float(frame_size.y)))
	var available_frames := mini(frame_count, columns * rows)
	for frame_index in range(available_frames):
		var column := frame_index % columns
		var row := int(floor(float(frame_index) / float(columns)))
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(Vector2(float(frame_size.x * column), float(frame_size.y * row)), Vector2(float(frame_size.x), float(frame_size.y)))
		frames.append(atlas)
	return frames


func _inventory_cell_size(board_rect: Rect2, grid_size: Vector2i, gap: Vector2) -> Vector2:
	var width := board_rect.size.x - gap.x * float(max(0, grid_size.x - 1))
	var height := board_rect.size.y - gap.y * float(max(0, grid_size.y - 1))
	return Vector2(floor(width / float(grid_size.x)), floor(height / float(grid_size.y)))


func _inventory_item_rect(board_size: Vector2, grid_position: Vector2i, item_size: Vector2i) -> Rect2:
	var inventory: Dictionary = layout.get("inventory", {})
	var grid_size := inventory_grid_size()
	var gap_value = inventory.get("gap", [8, 8])
	var gap := Vector2(float(gap_value[0]), float(gap_value[1]))
	var cell_size := _inventory_cell_size(Rect2(Vector2.ZERO, board_size), grid_size, gap)
	var position := Vector2(
		float(grid_position.x) * (cell_size.x + gap.x),
		float(grid_position.y) * (cell_size.y + gap.y)
	)
	var size := Vector2(
		float(item_size.x) * cell_size.x + float(max(0, item_size.x - 1)) * gap.x,
		float(item_size.y) * cell_size.y + float(max(0, item_size.y - 1)) * gap.y
	)
	return Rect2(position, size)


func _memory_item_visual_rect(board_size: Vector2, grid_position: Vector2i, item_size: Vector2i) -> Rect2:
	var rect := _inventory_item_rect(board_size, grid_position, item_size)
	var inset := Vector2(
		min(MEMORY_ITEM_INSET.x, max(0.0, rect.size.x * 0.08)),
		min(MEMORY_ITEM_INSET.y, max(0.0, rect.size.y * 0.08))
	)
	return Rect2(rect.position + inset, rect.size - inset * 2.0)


func _rect_from_array(values) -> Rect2:
	if typeof(values) != TYPE_ARRAY or values.size() != 4:
		return Rect2()
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


func _set_rect(control: Control, rect: Rect2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = rect.position
	control.size = rect.size
	control.custom_minimum_size = Vector2.ZERO


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


func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _load_memory_item_textures() -> void:
	memory_item_textures.clear()
	for memory_id in MEMORY_ITEM_ART_PATHS.keys():
		var texture := _load_texture(str(MEMORY_ITEM_ART_PATHS[memory_id]))
		if texture != null:
			memory_item_textures[str(memory_id)] = texture


func _load_actor_animation_textures() -> void:
	hero_static_texture = _load_texture(ART_HERO)
	enemy_static_texture = _load_texture(ART_ENEMY)
	hero_walk_sheet_texture = _load_texture(ART_HERO_WALK_SHEET)
	hero_attack_sheet_texture = _load_texture(ART_HERO_ATTACK_SHEET)
	enemy_idle_sheet_texture = _load_texture(ART_ENEMY_IDLE_SHEET)
	enemy_hit_sheet_texture = _load_texture(ART_ENEMY_HIT_SHEET)
	slash_effect_sheet_texture = _load_texture(ART_SLASH_EFFECT_SHEET)
	hit_burst_sheet_texture = _load_texture(ART_HIT_BURST_SHEET)
	hero_walk_frames = _build_sheet_frames(hero_walk_sheet_texture, ACTOR_ANIM_FRAME_SIZE, HERO_WALK_FRAMES, HERO_WALK_SHEET_COLUMNS)
	hero_attack_frames = _build_sheet_frames(hero_attack_sheet_texture, ACTOR_ANIM_FRAME_SIZE, HERO_ATTACK_FRAMES)
	enemy_idle_frames = _build_sheet_frames(enemy_idle_sheet_texture, ACTOR_ANIM_FRAME_SIZE, ACTOR_LOOP_FRAMES)
	enemy_hit_frames = _build_sheet_frames(enemy_hit_sheet_texture, ACTOR_ANIM_FRAME_SIZE, ENEMY_HIT_FRAMES)
	slash_effect_frames = _build_sheet_frames(slash_effect_sheet_texture, SLASH_ANIM_FRAME_SIZE, SLASH_FRAMES)
	hit_burst_frames = _build_sheet_frames(hit_burst_sheet_texture, HIT_BURST_ANIM_FRAME_SIZE, HIT_BURST_FRAMES)


func _new_texture_rect(texture_source, stretch_mode := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = stretch_mode
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if texture_source is Texture2D:
		texture_rect.texture = texture_source
	elif typeof(texture_source) == TYPE_STRING and not str(texture_source).is_empty():
		texture_rect.texture = _load_texture(str(texture_source))
	return texture_rect


func _add_button_art(button: Control) -> void:
	var art := _new_texture_rect(ART_BUTTON, TextureRect.STRETCH_SCALE)
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	art.modulate = Color(1, 1, 1, 0.96)
	button.add_child(art)


func _memory_item_texture(memory_id: String) -> Texture2D:
	if memory_item_textures.has(memory_id):
		return memory_item_textures[memory_id]
	return _memory_icon_texture(memory_id)


func _memory_icon_texture(memory_id: String) -> Texture2D:
	if memory_icons_texture == null:
		return null
	var icon_index := int(MEMORY_ICON_IDS.get(memory_id, abs(hash(memory_id)) % (MEMORY_ICON_ATLAS_COLUMNS * MEMORY_ICON_ATLAS_ROWS)))
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = memory_icons_texture
	var icon_size := Vector2(
		float(memory_icons_texture.get_width()) / float(MEMORY_ICON_ATLAS_COLUMNS),
		float(memory_icons_texture.get_height()) / float(MEMORY_ICON_ATLAS_ROWS)
	)
	var column := icon_index % MEMORY_ICON_ATLAS_COLUMNS
	var row := int(floor(float(icon_index) / float(MEMORY_ICON_ATLAS_COLUMNS))) % MEMORY_ICON_ATLAS_ROWS
	atlas_texture.region = Rect2(Vector2(float(column) * icon_size.x, float(row) * icon_size.y), icon_size)
	return atlas_texture


func _new_panel(kind: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	match kind:
		"cell_locked":
			style.bg_color = Color(0.20, 0.20, 0.18, 0.18)
			style.border_color = Color(0, 0, 0, 0)
		"cell_unlocked":
			style.bg_color = Color(1, 1, 1, 0.02)
			style.border_color = Color(0, 0, 0, 0)
		_:
			style.bg_color = Color(1, 1, 1, 0)
			style.border_color = Color(0, 0, 0, 0)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
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
