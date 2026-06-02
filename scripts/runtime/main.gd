extends Control

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")
const RunControllerScript := preload("res://scripts/runtime/run_controller.gd")
const BattleRunnerScript := preload("res://scripts/runtime/battle_runner.gd")
const EndingRunnerScript := preload("res://scripts/runtime/ending_runner.gd")
const SaveManagerScript := preload("res://scripts/runtime/save_manager.gd")
const MemoryCardViewScript := preload("res://scripts/ui/memory_card_view.gd")

var registry = DataRegistryScript.new()
var game_state = GameStateScript.new()
var script_player = ScriptPlayerScript.new()
var run_controller = RunControllerScript.new()
var battle_runner = BattleRunnerScript.new()
var ending_runner = EndingRunnerScript.new()
var save_manager = SaveManagerScript.new()
var active_script_node_id := ""
var active_ending: Dictionary = {}
var active_ending_lines: Array[Dictionary] = []
var active_ending_index := -1
var debug_status_label: Label
var debug_panel: PanelContainer
var bag_panel: Control
var bag_toggle_button: Button
var debug_toggle_button: Button
var ending_summary_layer: Control
var ending_summary_title_label: Label
var ending_summary_subtitle_label: Label
var ending_summary_name_label: Label
var ending_summary_reason_label: Label
var ending_summary_bag_label: Label
var ending_summary_lost_label: Label
var ending_summary_stats_label: Label

var name_label: Label
var status_label: Label
var progress_label: Label
var bg_label: Label
var bg_texture_rect: TextureRect
var portrait_texture_rect: TextureRect
var travel_stage: Control
var travel_panel_texture_rect: TextureRect
var travel_chibi_texture_rect: TextureRect
var travel_chibi_shadow: PanelContainer
var travel_step_marker: ColorRect
var travel_walk_sheet_texture: Texture2D
var travel_frame_index := 0
var travel_frame_timer := 0.0
var travel_chibi_base_top := 0.25
var battle_stage: Control
var battle_pressure_rect: ColorRect
var battle_hero_texture_rect: TextureRect
var battle_enemy_panel: PanelContainer
var battle_enemy_texture_rect: TextureRect
var battle_chibi_hero_shadow: PanelContainer
var battle_chibi_hero_texture_rect: TextureRect
var battle_chibi_enemy_shadow: PanelContainer
var battle_chibi_enemy_texture_rect: TextureRect
var chibi_hero_attack_sheet_texture: Texture2D
var battle_enemy_name_label: Label
var battle_enemy_type_label: Label
var battle_enemy_symbol_label: Label
var battle_enemy_hp_bar: ProgressBar
var battle_enemy_hp_label: Label
var battle_status_label: Label
var battle_slash_layer: Control
var battle_float_label: Label
var battle_hero_home := Vector2.ZERO
var battle_enemy_home := Vector2.ZERO
var battle_chibi_hero_home := Vector2.ZERO
var battle_chibi_enemy_home := Vector2.ZERO
var battle_animation_generation := 0
var dialogue_panel: Control
var dialogue_texture_rect: TextureRect
var nameplate_texture_rect: TextureRect
var bag_panel_texture_rect: TextureRect
var speaker_label: Label
var text_label: Label
var bag_grid: GridContainer
var memory_cards: Array[PanelContainer] = []
var quick_bag_bar: PanelContainer
var quick_bag_slots: Array[PanelContainer] = []
var trash_zone_card
var found_zone_card
var next_button: Button
var choices_box: VBoxContainer
var replacement_panel: PanelContainer
var replacement_new_card
var replacement_owned_box: VBoxContainer
var replacement_confirm_box: VBoxContainer
var replacement_confirm_label: Label
var pending_core_discard_id := ""
var ui_root: Control


func _ready() -> void:
	var ok := registry.load_all()
	print(registry.summary())
	for error in registry.validation_errors:
		push_error(error)
	_build_ui()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	if not ok:
		_show_load_error()
		return
	game_state.configure_from_balance(registry.balance)
	script_player.setup(registry, game_state)
	run_controller.setup(registry, game_state)
	battle_runner.setup(registry, game_state)
	ending_runner.setup(registry, game_state)
	script_player.event_changed.connect(_on_event_changed)
	script_player.memory_replacement_requested.connect(_on_memory_replacement_requested)
	script_player.script_finished.connect(_on_script_finished)
	run_controller.progress_changed.connect(_on_progress_changed)
	run_controller.node_triggered.connect(_on_run_node_triggered)
	script_player.start("P0001", "P0037")


func _process(delta: float) -> void:
	run_controller.tick(delta)
	_update_travel_stage_animation(delta)


func _build_ui() -> void:
	var root := Control.new()
	root.position = Vector2.ZERO
	root.size = _viewport_design_size()
	ui_root = root
	add_child(root)

	bg_texture_rect = TextureRect.new()
	bg_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_texture_rect.visible = false
	root.add_child(bg_texture_rect)

	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.color = Color(0.0, 0.0, 0.0, 0.18)
	root.add_child(vignette)

	portrait_texture_rect = TextureRect.new()
	portrait_texture_rect.anchor_left = 0.48
	portrait_texture_rect.anchor_top = 0.06
	portrait_texture_rect.anchor_right = 0.96
	portrait_texture_rect.anchor_bottom = 1.08
	portrait_texture_rect.offset_left = 0
	portrait_texture_rect.offset_top = 0
	portrait_texture_rect.offset_right = 0
	portrait_texture_rect.offset_bottom = 0
	portrait_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait_texture_rect.visible = false
	root.add_child(portrait_texture_rect)

	_build_travel_stage(root)
	_build_battle_stage(root)

	var top_bar := HBoxContainer.new()
	top_bar.anchor_left = 0.0
	top_bar.anchor_top = 0.0
	top_bar.anchor_right = 1.0
	top_bar.anchor_bottom = 0.0
	top_bar.offset_left = 24
	top_bar.offset_top = 18
	top_bar.offset_right = -24
	top_bar.offset_bottom = 54
	top_bar.add_theme_constant_override("separation", 10)
	root.add_child(top_bar)

	name_label = Label.new()
	name_label.visible = false

	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.70))
	top_bar.add_child(status_label)

	progress_label = Label.new()
	progress_label.text = "章节：序章"
	progress_label.add_theme_font_size_override("font_size", 15)
	progress_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.70))
	top_bar.add_child(progress_label)

	bag_toggle_button = Button.new()
	bag_toggle_button.text = "背包"
	bag_toggle_button.pressed.connect(_on_bag_toggle_pressed)
	top_bar.add_child(bag_toggle_button)

	var save_button := Button.new()
	save_button.text = "保存"
	save_button.pressed.connect(_on_save_pressed)
	top_bar.add_child(save_button)

	var load_button := Button.new()
	load_button.text = "读取"
	load_button.pressed.connect(_on_load_pressed)
	top_bar.add_child(load_button)

	debug_toggle_button = Button.new()
	debug_toggle_button.text = "调试"
	debug_toggle_button.pressed.connect(_on_debug_toggle_pressed)
	top_bar.add_child(debug_toggle_button)

	bg_label = Label.new()
	bg_label.visible = false

	dialogue_panel = Control.new()
	dialogue_panel.anchor_left = 0.04
	dialogue_panel.anchor_top = 0.50
	dialogue_panel.anchor_right = 0.96
	dialogue_panel.anchor_bottom = 0.665
	dialogue_panel.offset_left = 0
	dialogue_panel.offset_top = 0
	dialogue_panel.offset_right = 0
	dialogue_panel.offset_bottom = 0
	dialogue_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(dialogue_panel)

	dialogue_texture_rect = TextureRect.new()
	dialogue_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialogue_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	dialogue_panel.add_child(dialogue_texture_rect)

	var dialogue_margin := MarginContainer.new()
	dialogue_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialogue_margin.add_theme_constant_override("margin_left", 44)
	dialogue_margin.add_theme_constant_override("margin_top", 36)
	dialogue_margin.add_theme_constant_override("margin_right", 44)
	dialogue_margin.add_theme_constant_override("margin_bottom", 18)
	dialogue_panel.add_child(dialogue_margin)

	var dialogue_box := VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 8)
	dialogue_margin.add_child(dialogue_box)

	var speaker_row := Control.new()
	speaker_row.custom_minimum_size = Vector2(0, 34)
	dialogue_box.add_child(speaker_row)

	nameplate_texture_rect = TextureRect.new()
	nameplate_texture_rect.anchor_left = 0.0
	nameplate_texture_rect.anchor_top = 0.0
	nameplate_texture_rect.anchor_right = 0.0
	nameplate_texture_rect.anchor_bottom = 0.0
	nameplate_texture_rect.offset_left = -18
	nameplate_texture_rect.offset_top = -16
	nameplate_texture_rect.offset_right = 250
	nameplate_texture_rect.offset_bottom = 42
	nameplate_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nameplate_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	speaker_row.add_child(nameplate_texture_rect)

	speaker_label = Label.new()
	speaker_label.offset_left = 18
	speaker_label.offset_top = -2
	speaker_label.offset_right = 235
	speaker_label.offset_bottom = 40
	speaker_label.add_theme_font_size_override("font_size", 20)
	speaker_label.add_theme_color_override("font_color", Color(0.16, 0.10, 0.06))
	speaker_row.add_child(speaker_label)

	text_label = Label.new()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("font_size", 20)
	text_label.add_theme_color_override("font_color", Color(0.93, 0.89, 0.78))
	dialogue_box.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.anchor_left = 0.15
	choices_box.anchor_top = 0.29
	choices_box.anchor_right = 0.85
	choices_box.anchor_bottom = 0.49
	choices_box.add_theme_constant_override("separation", 10)
	root.add_child(choices_box)

	replacement_panel = PanelContainer.new()
	_apply_modal_panel_style(replacement_panel)
	replacement_panel.anchor_left = 0.12
	replacement_panel.anchor_top = 0.14
	replacement_panel.anchor_right = 0.88
	replacement_panel.anchor_bottom = 0.86
	replacement_panel.visible = false
	root.add_child(replacement_panel)

	var replacement_margin := MarginContainer.new()
	replacement_margin.add_theme_constant_override("margin_left", 12)
	replacement_margin.add_theme_constant_override("margin_top", 12)
	replacement_margin.add_theme_constant_override("margin_right", 12)
	replacement_margin.add_theme_constant_override("margin_bottom", 12)
	replacement_panel.add_child(replacement_margin)

	var replacement_box := VBoxContainer.new()
	replacement_box.add_theme_constant_override("separation", 8)
	replacement_margin.add_child(replacement_box)

	var replacement_title := Label.new()
	replacement_title.text = "背包已满，选择一段旧记忆留下，或放弃新记忆。"
	replacement_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	replacement_title.add_theme_font_size_override("font_size", 22)
	replacement_title.add_theme_color_override("font_color", Color(0.95, 0.88, 0.68))
	replacement_box.add_child(replacement_title)

	replacement_new_card = MemoryCardViewScript.new()
	replacement_box.add_child(replacement_new_card)

	replacement_owned_box = VBoxContainer.new()
	replacement_owned_box.add_theme_constant_override("separation", 6)
	replacement_box.add_child(replacement_owned_box)

	replacement_confirm_box = VBoxContainer.new()
	replacement_confirm_box.visible = false
	replacement_confirm_box.add_theme_constant_override("separation", 6)
	replacement_box.add_child(replacement_confirm_box)

	replacement_confirm_label = Label.new()
	replacement_confirm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	replacement_confirm_box.add_child(replacement_confirm_label)

	var confirm_buttons := HBoxContainer.new()
	confirm_buttons.add_theme_constant_override("separation", 8)
	replacement_confirm_box.add_child(confirm_buttons)

	var confirm_button := Button.new()
	confirm_button.text = "确认丢弃"
	confirm_button.pressed.connect(_on_confirm_core_discard_pressed)
	confirm_buttons.add_child(confirm_button)

	var cancel_button := Button.new()
	cancel_button.text = "取消"
	cancel_button.pressed.connect(_on_cancel_core_discard_pressed)
	confirm_buttons.add_child(cancel_button)

	bag_panel = Control.new()
	bag_panel.anchor_left = 0.70
	bag_panel.anchor_top = 0.08
	bag_panel.anchor_right = 0.98
	bag_panel.anchor_bottom = 0.86
	bag_panel.visible = false
	root.add_child(bag_panel)

	bag_panel_texture_rect = TextureRect.new()
	bag_panel_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	bag_panel_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bag_panel_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	bag_panel.add_child(bag_panel_texture_rect)

	var bag_margin := MarginContainer.new()
	bag_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	bag_margin.add_theme_constant_override("margin_left", 22)
	bag_margin.add_theme_constant_override("margin_top", 48)
	bag_margin.add_theme_constant_override("margin_right", 22)
	bag_margin.add_theme_constant_override("margin_bottom", 24)
	bag_panel.add_child(bag_margin)

	var bag_box := VBoxContainer.new()
	bag_box.add_theme_constant_override("separation", 10)
	bag_margin.add_child(bag_box)

	var bag_title := Label.new()
	bag_title.text = "记忆背包"
	bag_title.add_theme_font_size_override("font_size", 22)
	bag_title.add_theme_color_override("font_color", Color(0.91, 0.82, 0.64))
	bag_box.add_child(bag_title)

	var bag_scroll := ScrollContainer.new()
	bag_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bag_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bag_box.add_child(bag_scroll)

	bag_grid = GridContainer.new()
	bag_grid.columns = 1
	bag_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bag_scroll.add_child(bag_grid)
	for index in range(4):
		var card = MemoryCardViewScript.new()
		card.set_empty(index + 1)
		memory_cards.append(card)
		bag_grid.add_child(card)

	_build_quick_bag_bar(root)

	next_button = Button.new()
	next_button.text = "继续"
	next_button.anchor_left = 0.84
	next_button.anchor_top = 0.590
	next_button.anchor_right = 0.94
	next_button.anchor_bottom = 0.650
	next_button.add_theme_font_size_override("font_size", 18)
	next_button.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78))
	next_button.pressed.connect(_on_next_pressed)
	root.add_child(next_button)

	debug_panel = PanelContainer.new()
	_apply_modal_panel_style(debug_panel)
	debug_panel.anchor_left = 0.02
	debug_panel.anchor_top = 0.08
	debug_panel.anchor_right = 0.52
	debug_panel.anchor_bottom = 0.42
	debug_panel.visible = false
	root.add_child(debug_panel)

	var debug_margin := MarginContainer.new()
	debug_margin.add_theme_constant_override("margin_left", 10)
	debug_margin.add_theme_constant_override("margin_top", 8)
	debug_margin.add_theme_constant_override("margin_right", 10)
	debug_margin.add_theme_constant_override("margin_bottom", 8)
	debug_panel.add_child(debug_margin)

	var debug_box := VBoxContainer.new()
	debug_box.add_theme_constant_override("separation", 6)
	debug_margin.add_child(debug_box)

	var debug_title := Label.new()
	debug_title.text = "调试面板"
	debug_title.add_theme_font_size_override("font_size", 16)
	debug_box.add_child(debug_title)

	var jump_box := HBoxContainer.new()
	jump_box.add_theme_constant_override("separation", 6)
	debug_box.add_child(jump_box)
	for target_event_id in ["P0034", "F0010", "F0021", "F0034", "F0040"]:
		var jump_button := Button.new()
		jump_button.text = target_event_id
		jump_button.pressed.connect(_on_debug_jump_pressed.bind(target_event_id))
		jump_box.add_child(jump_button)

	var memory_box := HBoxContainer.new()
	memory_box.add_theme_constant_override("separation", 6)
	debug_box.add_child(memory_box)
	for memory_id in ["mem_mothers_soup", "mem_wooden_sword", "mem_reason_to_depart", "mem_my_name", "mem_someone_waits", "mem_empty_nameplate"]:
		var add_button := Button.new()
		add_button.text = "+%s" % registry.memories.get(memory_id, {}).get("name", memory_id)
		add_button.pressed.connect(_on_debug_add_memory_pressed.bind(memory_id))
		memory_box.add_child(add_button)

	var ending_box := HBoxContainer.new()
	ending_box.add_theme_constant_override("separation", 6)
	debug_box.add_child(ending_box)
	for ending_id in ["mvp_named_with_reason", "mvp_named_without_reason", "mvp_nameless_with_reason", "mvp_nameless_without_reason"]:
		var ending_button := Button.new()
		ending_button.text = ending_id
		ending_button.pressed.connect(_on_debug_force_ending_pressed.bind(ending_id))
		ending_box.add_child(ending_button)

	debug_status_label = Label.new()
	debug_status_label.text = "调试：待命"
	debug_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_box.add_child(debug_status_label)

	_build_ending_summary_layer(root)

	_apply_static_ui_art()
	_apply_button_texture_style(next_button, "ui_choice_button")


func _build_ending_summary_layer(root: Control) -> void:
	ending_summary_layer = Control.new()
	ending_summary_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	ending_summary_layer.visible = false
	root.add_child(ending_summary_layer)

	var shade := ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.46)
	ending_summary_layer.add_child(shade)

	var panel := PanelContainer.new()
	_apply_modal_panel_style(panel)
	panel.anchor_left = 0.18
	panel.anchor_top = 0.13
	panel.anchor_right = 0.82
	panel.anchor_bottom = 0.84
	ending_summary_layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	ending_summary_title_label = Label.new()
	ending_summary_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_summary_title_label.add_theme_font_size_override("font_size", 31)
	ending_summary_title_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))
	box.add_child(ending_summary_title_label)

	ending_summary_subtitle_label = Label.new()
	ending_summary_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_summary_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ending_summary_subtitle_label.add_theme_font_size_override("font_size", 18)
	ending_summary_subtitle_label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	box.add_child(ending_summary_subtitle_label)

	var divider := HSeparator.new()
	box.add_child(divider)

	ending_summary_name_label = _new_summary_label(21, Color(0.93, 0.89, 0.78))
	box.add_child(ending_summary_name_label)

	ending_summary_reason_label = _new_summary_label(21, Color(0.93, 0.89, 0.78))
	box.add_child(ending_summary_reason_label)

	ending_summary_bag_label = _new_summary_label(18, Color(0.82, 0.78, 0.67))
	box.add_child(ending_summary_bag_label)

	ending_summary_lost_label = _new_summary_label(18, Color(0.82, 0.78, 0.67))
	box.add_child(ending_summary_lost_label)

	ending_summary_stats_label = _new_summary_label(17, Color(0.76, 0.72, 0.63))
	box.add_child(ending_summary_stats_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 10)
	box.add_child(button_row)

	var close_button := Button.new()
	close_button.text = "关闭回顾"
	close_button.custom_minimum_size = Vector2(150, 46)
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78))
	close_button.pressed.connect(func(): ending_summary_layer.visible = false)
	_apply_flat_button_style(close_button)
	button_row.add_child(close_button)


func _new_summary_label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _build_quick_bag_bar(root: Control) -> void:
	quick_bag_bar = PanelContainer.new()
	quick_bag_bar.anchor_left = 0.05
	quick_bag_bar.anchor_top = 0.69
	quick_bag_bar.anchor_right = 0.95
	quick_bag_bar.anchor_bottom = 0.965
	quick_bag_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	_apply_battle_enemy_style(quick_bag_bar, Color(0.070, 0.052, 0.034, 0.94), Color(0.70, 0.49, 0.22, 0.98), 8)
	root.add_child(quick_bag_bar)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 12)
	quick_bag_bar.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var trash_section := VBoxContainer.new()
	trash_section.custom_minimum_size = Vector2(170, 0)
	trash_section.add_theme_constant_override("separation", 8)
	row.add_child(trash_section)

	var trash_label := _new_tray_label("弃牌堆")
	trash_section.add_child(trash_label)

	trash_zone_card = MemoryCardViewScript.new()
	trash_zone_card.set_compact(true)
	trash_zone_card.custom_minimum_size = Vector2(160, 130)
	trash_zone_card.set_zone("弃牌堆", "拖入丢弃", "trash")
	trash_zone_card.configure_drop_target("trash")
	trash_zone_card.memory_dropped.connect(_on_memory_card_dropped)
	trash_section.add_child(trash_zone_card)

	var bag_section := VBoxContainer.new()
	bag_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_section.add_theme_constant_override("separation", 8)
	row.add_child(bag_section)

	var bag_label := _new_tray_label("记忆背包")
	bag_section.add_child(bag_label)

	var quick_bag_grid := GridContainer.new()
	quick_bag_grid.columns = 2
	quick_bag_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quick_bag_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	quick_bag_grid.add_theme_constant_override("h_separation", 10)
	quick_bag_grid.add_theme_constant_override("v_separation", 10)
	bag_section.add_child(quick_bag_grid)

	for index in range(4):
		var slot = MemoryCardViewScript.new()
		slot.set_compact(true)
		slot.custom_minimum_size = Vector2(170, 72)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.configure_drop_target("bag", index)
		slot.memory_dropped.connect(_on_memory_card_dropped)
		quick_bag_slots.append(slot)
		quick_bag_grid.add_child(slot)

	var found_section := VBoxContainer.new()
	found_section.custom_minimum_size = Vector2(190, 0)
	found_section.add_theme_constant_override("separation", 8)
	row.add_child(found_section)

	var found_label := _new_tray_label("新记忆")
	found_section.add_child(found_label)

	found_zone_card = MemoryCardViewScript.new()
	found_zone_card.set_compact(true)
	found_zone_card.custom_minimum_size = Vector2(180, 130)
	found_zone_card.set_zone("新发现", "等待拾取", "found")
	found_zone_card.configure_drop_target("found")
	found_zone_card.memory_dropped.connect(_on_memory_card_dropped)
	found_section.add_child(found_zone_card)


func _new_tray_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.95, 0.84, 0.56))
	return label


func _build_travel_stage(root: Control) -> void:
	travel_stage = Control.new()
	travel_stage.anchor_left = 0.15
	travel_stage.anchor_top = 0.12
	travel_stage.anchor_right = 0.85
	travel_stage.anchor_bottom = 0.47
	travel_stage.visible = false
	travel_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(travel_stage)

	travel_panel_texture_rect = TextureRect.new()
	travel_panel_texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	travel_panel_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	travel_panel_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	travel_stage.add_child(travel_panel_texture_rect)

	travel_step_marker = ColorRect.new()
	travel_step_marker.anchor_left = 0.12
	travel_step_marker.anchor_top = 0.68
	travel_step_marker.anchor_right = 0.88
	travel_step_marker.anchor_bottom = 0.71
	travel_step_marker.color = Color(0.95, 0.82, 0.48, 0.26)
	travel_stage.add_child(travel_step_marker)

	travel_chibi_shadow = PanelContainer.new()
	travel_chibi_shadow.anchor_left = 0.45
	travel_chibi_shadow.anchor_top = 0.80
	travel_chibi_shadow.anchor_right = 0.55
	travel_chibi_shadow.anchor_bottom = 0.86
	_apply_chibi_shadow_style(travel_chibi_shadow)
	travel_chibi_shadow.modulate = Color(1.0, 1.0, 1.0, 0.20)
	travel_stage.add_child(travel_chibi_shadow)

	travel_chibi_texture_rect = TextureRect.new()
	travel_chibi_texture_rect.anchor_left = 0.40
	travel_chibi_texture_rect.anchor_top = 0.25
	travel_chibi_texture_rect.anchor_right = 0.60
	travel_chibi_texture_rect.anchor_bottom = 0.86
	travel_chibi_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	travel_chibi_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	travel_stage.add_child(travel_chibi_texture_rect)


func _build_battle_stage(root: Control) -> void:
	battle_stage = Control.new()
	battle_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	battle_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battle_stage.visible = false
	root.add_child(battle_stage)

	battle_pressure_rect = ColorRect.new()
	battle_pressure_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	battle_pressure_rect.color = Color(0.12, 0.02, 0.03, 0.0)
	battle_pressure_rect.visible = false
	battle_stage.add_child(battle_pressure_rect)

	battle_hero_texture_rect = TextureRect.new()
	battle_hero_texture_rect.set_anchors_preset(Control.PRESET_TOP_LEFT)
	battle_hero_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battle_hero_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battle_stage.add_child(battle_hero_texture_rect)

	battle_chibi_hero_shadow = PanelContainer.new()
	battle_chibi_hero_shadow.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_apply_chibi_shadow_style(battle_chibi_hero_shadow)
	battle_chibi_hero_shadow.modulate = Color(1.0, 1.0, 1.0, 0.22)
	battle_stage.add_child(battle_chibi_hero_shadow)

	battle_chibi_hero_texture_rect = TextureRect.new()
	battle_chibi_hero_texture_rect.set_anchors_preset(Control.PRESET_TOP_LEFT)
	battle_chibi_hero_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battle_chibi_hero_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battle_stage.add_child(battle_chibi_hero_texture_rect)

	battle_chibi_enemy_shadow = PanelContainer.new()
	battle_chibi_enemy_shadow.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_apply_chibi_shadow_style(battle_chibi_enemy_shadow)
	battle_chibi_enemy_shadow.modulate = Color(1.0, 1.0, 1.0, 0.20)
	battle_stage.add_child(battle_chibi_enemy_shadow)

	battle_chibi_enemy_texture_rect = TextureRect.new()
	battle_chibi_enemy_texture_rect.set_anchors_preset(Control.PRESET_TOP_LEFT)
	battle_chibi_enemy_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battle_chibi_enemy_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battle_stage.add_child(battle_chibi_enemy_texture_rect)

	battle_enemy_panel = PanelContainer.new()
	battle_enemy_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_apply_battle_enemy_style(battle_enemy_panel)
	battle_stage.add_child(battle_enemy_panel)

	var enemy_margin := MarginContainer.new()
	enemy_margin.add_theme_constant_override("margin_left", 12)
	enemy_margin.add_theme_constant_override("margin_top", 10)
	enemy_margin.add_theme_constant_override("margin_right", 12)
	enemy_margin.add_theme_constant_override("margin_bottom", 10)
	battle_enemy_panel.add_child(enemy_margin)

	var enemy_box := VBoxContainer.new()
	enemy_box.add_theme_constant_override("separation", 5)
	enemy_margin.add_child(enemy_box)

	battle_enemy_name_label = Label.new()
	battle_enemy_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_enemy_name_label.add_theme_font_size_override("font_size", 18)
	battle_enemy_name_label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.70))
	enemy_box.add_child(battle_enemy_name_label)

	battle_enemy_type_label = Label.new()
	battle_enemy_type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_enemy_type_label.add_theme_font_size_override("font_size", 12)
	battle_enemy_type_label.add_theme_color_override("font_color", Color(0.67, 0.62, 0.50))
	enemy_box.add_child(battle_enemy_type_label)

	battle_enemy_symbol_label = Label.new()
	battle_enemy_symbol_label.text = "◇"
	battle_enemy_symbol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_enemy_symbol_label.add_theme_font_size_override("font_size", 74)
	battle_enemy_symbol_label.add_theme_color_override("font_color", Color(0.18, 0.18, 0.18, 0.92))
	battle_enemy_symbol_label.visible = false
	enemy_box.add_child(battle_enemy_symbol_label)

	battle_enemy_texture_rect = TextureRect.new()
	battle_enemy_texture_rect.custom_minimum_size = Vector2(138, 96)
	battle_enemy_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battle_enemy_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battle_enemy_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battle_enemy_texture_rect.visible = false
	enemy_box.add_child(battle_enemy_texture_rect)

	battle_enemy_hp_bar = ProgressBar.new()
	battle_enemy_hp_bar.min_value = 0
	battle_enemy_hp_bar.max_value = 1
	battle_enemy_hp_bar.value = 1
	battle_enemy_hp_bar.show_percentage = false
	enemy_box.add_child(battle_enemy_hp_bar)

	battle_enemy_hp_label = Label.new()
	battle_enemy_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_enemy_hp_label.add_theme_font_size_override("font_size", 13)
	battle_enemy_hp_label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.72))
	enemy_box.add_child(battle_enemy_hp_label)

	battle_status_label = Label.new()
	battle_status_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	battle_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	battle_status_label.add_theme_font_size_override("font_size", 22)
	battle_status_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.62))
	battle_stage.add_child(battle_status_label)

	battle_slash_layer = Control.new()
	battle_slash_layer.set_anchors_preset(Control.PRESET_TOP_LEFT)
	battle_slash_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battle_slash_layer.visible = false
	battle_stage.add_child(battle_slash_layer)

	battle_float_label = Label.new()
	battle_float_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	battle_float_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_float_label.add_theme_font_size_override("font_size", 31)
	battle_float_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.46))
	battle_float_label.visible = false
	battle_stage.add_child(battle_float_label)
	_layout_battle_stage()


func _show_load_error() -> void:
	_show_dialogue_ui()
	name_label.text = "记忆背包"
	status_label.text = "数据校验失败"
	progress_label.text = ""
	bg_label.text = ""
	_clear_art_preview()
	speaker_label.text = "系统"
	text_label.text = "\n".join(registry.validation_errors)
	_update_bag_cards()
	next_button.disabled = true


func _on_event_changed(event: Dictionary) -> void:
	if not game_state.has_pending_memory():
		replacement_panel.visible = false
		pending_core_discard_id = ""
	_show_dialogue_ui()
	_update_static_labels(event)
	_rebuild_choices(event)
	if game_state.has_pending_memory():
		_show_backpack_ui()


func _on_script_finished() -> void:
	if run_controller.chapter_id.is_empty():
		run_controller.start_chapter("forest")
		return
	if _should_start_mvp_ending():
		_start_mvp_ending()
		return
	active_script_node_id = ""
	_update_header_status()
	bg_label.text = ""
	_clear_art_preview()
	speaker_label.text = "系统"
	text_label.text = "继续前进。"
	_clear_choices()
	_show_backpack_ui()
	_update_bag_cards()
	run_controller.resume()


func _update_static_labels(event: Dictionary) -> void:
	name_label.text = "名字：%s" % game_state.display_name
	_update_header_status()
	bg_label.text = "背景：%s / 立绘：%s" % [event.get("bg", ""), event.get("portrait", "")]
	_apply_event_art(event)
	speaker_label.text = str(event.get("speaker", ""))
	text_label.text = str(event.get("text", ""))
	_update_bag_cards()


func _update_bag_cards() -> void:
	var capacity: int = int(registry.balance.get("bag", {}).get("capacity_base", 4))
	for index in memory_cards.size():
		var card = memory_cards[index]
		if index >= capacity:
			card.visible = false
			continue
		card.visible = true
		if index < game_state.owned_memory_ids.size():
			var memory_id: String = str(game_state.owned_memory_ids[index])
			var memory: Dictionary = registry.memories.get(memory_id, {})
			card.configure_drop_target("bag", index)
			card.set_memory(memory, registry.get_art_asset_for_memory(memory_id), memory_id)
		else:
			card.configure_drop_target("bag", index)
			card.set_empty(index + 1)
	_update_quick_bag_cards(capacity)


func _update_quick_bag_cards(capacity: int) -> void:
	for index in quick_bag_slots.size():
		var slot = quick_bag_slots[index]
		slot.visible = index < capacity
		slot.configure_drop_target("bag", index)
		if index < game_state.owned_memory_ids.size():
			var memory_id: String = str(game_state.owned_memory_ids[index])
			slot.set_memory(registry.memories.get(memory_id, {}), registry.get_art_asset_for_memory(memory_id), memory_id)
		else:
			slot.set_empty(index + 1)
	if found_zone_card != null:
		found_zone_card.configure_drop_target("found")
		if game_state.has_pending_memory():
			var pending_id: String = game_state.pending_memory_id
			found_zone_card.set_memory(registry.memories.get(pending_id, {}), registry.get_art_asset_for_memory(pending_id), pending_id)
		else:
			found_zone_card.set_zone("新发现", "等待拾取", "found")


func _rebuild_choices(event: Dictionary) -> void:
	_clear_choices()
	var is_choice := str(event.get("type", "")) == "choice"
	next_button.visible = not is_choice
	if dialogue_panel != null and dialogue_panel.visible:
		_set_bottom_ui_mode("dialogue")
	if not is_choice:
		return
	var visible_options := script_player.get_visible_options(event)
	for index in visible_options.size():
		var option: Dictionary = visible_options[index]
		var button := Button.new()
		button.text = str(option.get("label", ""))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 58)
		button.add_theme_font_size_override("font_size", 20)
		button.add_theme_color_override("font_color", Color(0.94, 0.90, 0.78))
		_apply_button_texture_style(button, "ui_choice_button")
		button.pressed.connect(_on_choice_pressed.bind(index))
		choices_box.add_child(button)


func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()


func _on_next_pressed() -> void:
	if not active_ending_lines.is_empty():
		_advance_ending()
		return
	script_player.advance()


func _on_choice_pressed(index: int) -> void:
	script_player.select_choice(index)


func _on_progress_changed(chapter_id: String, progress: float, chapter_distance: float) -> void:
	progress_label.text = "章节：%s  距离：%dm / %dm" % [
		_chapter_name(chapter_id),
		int(progress),
		int(chapter_distance),
	]


func _on_run_node_triggered(node: Dictionary) -> void:
	var node_type := str(node.get("type", ""))
	active_script_node_id = str(node.get("node_id", ""))
	if node_type == "script_sequence":
		script_player.start(str(node.get("start_event_id", "")), str(node.get("end_event_id", "")))
	elif node_type == "event":
		var event_id := str(node.get("event_id", ""))
		var event: Dictionary = registry.script_events.get(event_id, {})
		if str(event.get("type", "")) == "battle":
			_run_battle_event(event)
		else:
			script_player.start(event_id, event_id)
	else:
		run_controller.resume()


func _run_battle_event(event: Dictionary) -> void:
	replacement_panel.visible = false
	pending_core_discard_id = ""
	_show_backpack_ui()
	var result := battle_runner.run_event(event)
	_update_battle_labels(event, result)
	call_deferred("_play_battle_result_then_resume", result)


func _on_memory_replacement_requested(memory_id: String, _next_event_id: String) -> void:
	_show_backpack_ui()
	replacement_panel.visible = false
	pending_core_discard_id = ""
	replacement_confirm_box.visible = false
	replacement_new_card.visible = false
	replacement_owned_box.visible = false
	var memory: Dictionary = registry.memories.get(memory_id, {})
	replacement_new_card.set_memory(memory, registry.get_art_asset_for_memory(memory_id), memory_id)
	_rebuild_replacement_options()
	_update_bag_cards()


func _rebuild_replacement_options() -> void:
	for child in replacement_owned_box.get_children():
		child.queue_free()
	for memory_id in game_state.owned_memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		var button := Button.new()
		button.text = "丢弃：%s - %s" % [
			memory.get("name", memory_id),
			memory.get("ui_loss_hint", ""),
		]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 44)
		button.add_theme_font_size_override("font_size", 16)
		_apply_button_texture_style(button, "ui_choice_button")
		button.pressed.connect(_on_discard_for_pending_pressed.bind(str(memory_id)))
		replacement_owned_box.add_child(button)
	var decline_button := Button.new()
	decline_button.text = "放弃新记忆：%s" % registry.memories.get(game_state.pending_memory_id, {}).get("name", game_state.pending_memory_id)
	decline_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	decline_button.custom_minimum_size = Vector2(0, 44)
	decline_button.add_theme_font_size_override("font_size", 16)
	_apply_button_texture_style(decline_button, "ui_choice_button")
	decline_button.pressed.connect(_on_decline_pending_memory_pressed)
	replacement_owned_box.add_child(decline_button)


func _on_discard_for_pending_pressed(memory_id: String) -> void:
	var memory: Dictionary = registry.memories.get(memory_id, {})
	if bool(memory.get("is_core", false)):
		pending_core_discard_id = memory_id
		replacement_new_card.visible = game_state.has_pending_memory()
		replacement_owned_box.visible = false
		var confirm_text := str(registry.balance.get("memory_replace", {}).get("core_confirm_text_by_memory", {}).get(
			memory_id,
			registry.balance.get("memory_replace", {}).get("default_confirm_text", "")
		))
		replacement_confirm_label.text = confirm_text
		replacement_confirm_box.visible = true
		return
	_accept_pending_by_discard(memory_id)


func _on_confirm_core_discard_pressed() -> void:
	if pending_core_discard_id.is_empty():
		return
	var memory_id := pending_core_discard_id
	if game_state.has_pending_memory():
		_accept_pending_by_discard(memory_id)
		return
	pending_core_discard_id = ""
	replacement_panel.visible = false
	replacement_confirm_box.visible = false
	replacement_new_card.visible = false
	replacement_owned_box.visible = false
	game_state.discard_memory(memory_id)
	var memory: Dictionary = registry.memories.get(memory_id, {})
	game_state.world_feedback_history.append("%s：%s" % [
		memory.get("name", memory_id),
		memory.get("discard_text", "这段核心记忆被丢进了垃圾堆。"),
	])
	_update_header_status()
	_update_bag_cards()


func _on_cancel_core_discard_pressed() -> void:
	pending_core_discard_id = ""
	replacement_confirm_box.visible = false
	replacement_panel.visible = false
	replacement_new_card.visible = false
	replacement_owned_box.visible = false


func _on_decline_pending_memory_pressed() -> void:
	game_state.decline_pending_memory()
	replacement_panel.visible = false
	replacement_confirm_box.visible = false
	replacement_new_card.visible = false
	replacement_owned_box.visible = false
	script_player.finish_memory_replacement()
	_update_bag_cards()


func _on_memory_card_dropped(data: Dictionary, target_kind: String, target_index: int) -> void:
	var memory_id := str(data.get("memory_id", ""))
	var source_kind := str(data.get("source_kind", ""))
	var source_index := int(data.get("source_index", -1))
	if memory_id.is_empty():
		return
	if target_kind == "trash":
		_discard_memory_from_drag(memory_id)
	elif target_kind == "bag":
		if source_kind == "found" and game_state.has_pending_memory():
			_accept_pending_into_slot(target_index)
		elif source_kind == "card" or source_kind == "bag":
			_move_memory_slot(source_index, target_index)
	elif target_kind == "found" and source_kind == "bag":
		_move_memory_slot(source_index, game_state.owned_memory_ids.size() - 1)
	_update_bag_cards()


func _discard_memory_from_drag(memory_id: String) -> void:
	if game_state.has_pending_memory() and memory_id == game_state.pending_memory_id:
		_on_decline_pending_memory_pressed()
		return
	var memory: Dictionary = registry.memories.get(memory_id, {})
	if bool(memory.get("is_core", false)):
		pending_core_discard_id = memory_id
		replacement_new_card.visible = false
		replacement_owned_box.visible = false
		replacement_confirm_label.text = str(registry.balance.get("memory_replace", {}).get("core_confirm_text_by_memory", {}).get(
			memory_id,
			registry.balance.get("memory_replace", {}).get("default_confirm_text", "")
		))
		replacement_panel.visible = true
		replacement_confirm_box.visible = true
		return
	game_state.discard_memory(memory_id)
	game_state.world_feedback_history.append("%s：%s" % [
		memory.get("name", memory_id),
		memory.get("discard_text", "这段记忆被丢进了垃圾堆。"),
	])
	_update_header_status()


func _accept_pending_into_slot(target_index: int) -> void:
	if not game_state.has_pending_memory():
		return
	var pending_id: String = game_state.pending_memory_id
	if target_index >= 0 and target_index < game_state.owned_memory_ids.size():
		var replaced_id := str(game_state.owned_memory_ids[target_index])
		var replaced_memory: Dictionary = registry.memories.get(replaced_id, {})
		if bool(replaced_memory.get("is_core", false)):
			pending_core_discard_id = replaced_id
			replacement_new_card.set_memory(registry.memories.get(pending_id, {}), registry.get_art_asset_for_memory(pending_id), pending_id)
			replacement_new_card.visible = true
			replacement_owned_box.visible = false
			replacement_confirm_label.text = str(registry.balance.get("memory_replace", {}).get("core_confirm_text_by_memory", {}).get(
				replaced_id,
				registry.balance.get("memory_replace", {}).get("default_confirm_text", "")
			))
			replacement_panel.visible = true
			replacement_confirm_box.visible = true
			return
		game_state.accept_pending_by_discard(replaced_id, registry)
	else:
		game_state.gain_memory(pending_id)
		game_state.pending_memory_id = ""
		if target_index >= 0 and target_index < game_state.owned_memory_ids.size():
			var current_index: int = game_state.owned_memory_ids.find(pending_id)
			if current_index >= 0 and current_index != target_index:
				game_state.owned_memory_ids.remove_at(current_index)
				game_state.owned_memory_ids.insert(target_index, pending_id)
	replacement_panel.visible = false
	replacement_confirm_box.visible = false
	replacement_new_card.visible = false
	replacement_owned_box.visible = false
	pending_core_discard_id = ""
	script_player.finish_memory_replacement()


func _move_memory_slot(source_index: int, target_index: int) -> void:
	if source_index < 0 or target_index < 0:
		return
	if source_index >= game_state.owned_memory_ids.size() or target_index >= game_state.owned_memory_ids.size():
		return
	if source_index == target_index:
		return
	var value: String = game_state.owned_memory_ids[source_index]
	game_state.owned_memory_ids[source_index] = game_state.owned_memory_ids[target_index]
	game_state.owned_memory_ids[target_index] = value


func _on_save_pressed() -> void:
	var ok := save_manager.save_to_file(SaveManagerScript.DEFAULT_SAVE_PATH, game_state, run_controller, script_player, _ui_save_context())
	debug_status_label.text = "调试：已保存" if ok else "调试：%s" % save_manager.last_error


func _on_load_pressed() -> void:
	var ui := save_manager.load_from_file(SaveManagerScript.DEFAULT_SAVE_PATH, game_state, run_controller, script_player)
	if save_manager.last_error != "":
		debug_status_label.text = "调试：%s" % save_manager.last_error
		return
	_restore_ui_context(ui)
	debug_status_label.text = "调试：已读取"
	_update_bag_cards()


func _on_bag_toggle_pressed() -> void:
	bag_panel.visible = not bag_panel.visible


func _on_debug_toggle_pressed() -> void:
	debug_panel.visible = not debug_panel.visible


func _ui_save_context() -> Dictionary:
	return {
		"active_script_node_id": active_script_node_id,
		"active_ending": active_ending.duplicate(true),
		"active_ending_lines": active_ending_lines.duplicate(true),
		"active_ending_index": active_ending_index,
	}


func _restore_ui_context(ui: Dictionary) -> void:
	active_script_node_id = str(ui.get("active_script_node_id", ""))
	active_ending = ui.get("active_ending", {}).duplicate(true) if typeof(ui.get("active_ending", {})) == TYPE_DICTIONARY else {}
	active_ending_lines = _read_dictionary_array(ui.get("active_ending_lines", []))
	active_ending_index = int(ui.get("active_ending_index", -1))
	if not active_ending_lines.is_empty() and active_ending_index >= 0 and active_ending_index < active_ending_lines.size():
		active_ending_index -= 1
		_advance_ending()
	elif not game_state.current_event_id.is_empty():
		var event: Dictionary = registry.script_events.get(game_state.current_event_id, {})
		if not event.is_empty():
			_update_static_labels(event)
			_rebuild_choices(event)
	else:
		_update_header_status()
		speaker_label.text = "系统"
		text_label.text = "继续前进。"
		_show_backpack_ui()


func _read_dictionary_array(value) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(item.duplicate(true))
	return result


func _on_debug_jump_pressed(event_id: String) -> void:
	debug_jump_to_event(event_id)
	debug_status_label.text = "调试：已跳转到 %s" % event_id


func debug_jump_to_event(event_id: String) -> void:
	_cancel_battle_animation()
	_hide_ending_summary()
	active_ending_lines.clear()
	active_ending = {}
	active_ending_index = -1
	if event_id.begins_with("P"):
		active_script_node_id = ""
		run_controller.pause()
		script_player.start(event_id, event_id)
		return
	run_controller.start_chapter("forest")
	var target_node := _find_node_for_event(event_id)
	var target_progress: float = float(target_node.get("progress", run_controller.progress)) if not target_node.is_empty() else run_controller.progress
	run_controller.pause()
	run_controller.progress = target_progress
	run_controller.debug_mark_nodes_before(target_progress)
	run_controller.progress_changed.emit(run_controller.chapter_id, run_controller.progress, _chapter_distance_for("forest"))
	active_script_node_id = str(target_node.get("node_id", ""))
	var event: Dictionary = registry.script_events.get(event_id, {})
	if str(event.get("type", "")) == "battle":
		_run_battle_event(event)
	else:
		script_player.start(event_id, event_id)


func _find_node_for_event(event_id: String) -> Dictionary:
	var event_index: int = registry.script_event_order.find(event_id)
	for chapter in registry.chapter_flow.get("chapters", []):
		if typeof(chapter) != TYPE_DICTIONARY:
			continue
		for node in chapter.get("nodes", []):
			if typeof(node) != TYPE_DICTIONARY:
				continue
			if str(node.get("event_id", "")) == event_id:
				return node
			if str(node.get("start_event_id", "")) == event_id or str(node.get("end_event_id", "")) == event_id:
				return node
			var start_index: int = registry.script_event_order.find(str(node.get("start_event_id", "")))
			var end_index: int = registry.script_event_order.find(str(node.get("end_event_id", "")))
			if event_index != -1 and start_index != -1 and end_index != -1 and event_index >= start_index and event_index <= end_index:
				return node
	return {}


func _chapter_distance_for(chapter_id: String) -> float:
	for chapter in registry.chapter_flow.get("chapters", []):
		if typeof(chapter) == TYPE_DICTIONARY and str(chapter.get("chapter_id", "")) == chapter_id:
			return float(chapter.get("distance", 0.0))
	return 0.0


func _on_debug_add_memory_pressed(memory_id: String) -> void:
	if game_state.has_memory(memory_id):
		game_state.discard_memory(memory_id)
		debug_status_label.text = "调试：移除记忆 %s" % registry.memories.get(memory_id, {}).get("name", memory_id)
	else:
		game_state.gain_memory(memory_id)
		debug_status_label.text = "调试：添加记忆 %s" % registry.memories.get(memory_id, {}).get("name", memory_id)
	_update_bag_cards()


func _on_debug_force_ending_pressed(ending_id: String) -> void:
	_apply_debug_ending_memory_state(ending_id)
	_start_mvp_ending()
	debug_status_label.text = "调试：强制结尾 %s" % ending_id


func _apply_debug_ending_memory_state(ending_id: String) -> void:
	if ending_id == "mvp_named_with_reason":
		game_state.gain_memory("mem_my_name")
		game_state.gain_memory("mem_reason_to_depart")
	elif ending_id == "mvp_named_without_reason":
		game_state.gain_memory("mem_my_name")
		game_state.discard_memory("mem_reason_to_depart")
	elif ending_id == "mvp_nameless_with_reason":
		game_state.discard_memory("mem_my_name")
		game_state.gain_memory("mem_reason_to_depart")
	elif ending_id == "mvp_nameless_without_reason":
		game_state.discard_memory("mem_my_name")
		game_state.discard_memory("mem_reason_to_depart")


func _accept_pending_by_discard(memory_id: String) -> void:
	game_state.accept_pending_by_discard(memory_id, registry)
	replacement_panel.visible = false
	replacement_confirm_box.visible = false
	pending_core_discard_id = ""
	script_player.finish_memory_replacement()
	_update_bag_cards()


func _chapter_name(chapter_id: String) -> String:
	for chapter in registry.chapter_flow.get("chapters", []):
		if typeof(chapter) == TYPE_DICTIONARY and str(chapter.get("chapter_id", "")) == chapter_id:
			return str(chapter.get("name", chapter_id))
	return chapter_id


func _should_start_mvp_ending() -> bool:
	return active_script_node_id == str(registry.mvp_endings.get("trigger_after_node_id", ""))


func _start_mvp_ending() -> void:
	_cancel_battle_animation()
	_hide_ending_summary()
	run_controller.pause()
	active_script_node_id = ""
	active_ending = ending_runner.evaluate_mvp_ending()
	active_ending_lines = active_ending.get("lines", [])
	active_ending_index = -1
	if active_ending_lines.is_empty():
		_show_dialogue_ui()
		status_label.text = "MVP 结尾判定失败"
		bg_label.text = ""
		speaker_label.text = "系统"
		text_label.text = "没有匹配到 MVP 结尾规则。"
		next_button.visible = false
		return
	_advance_ending()


func _advance_ending() -> void:
	active_ending_index += 1
	if active_ending_index >= active_ending_lines.size():
		_show_dialogue_ui()
		_update_header_status()
		speaker_label.text = "系统"
		text_label.text = "MVP 到此结束。"
		next_button.visible = false
		active_ending_lines.clear()
		_update_bag_cards()
		_show_ending_summary()
		return
	var line: Dictionary = active_ending_lines[active_ending_index]
	_show_dialogue_ui()
	name_label.text = "名字：%s" % game_state.display_name
	status_label.text = "结尾 %d/%d  ·  %s" % [
		active_ending_index + 1,
		active_ending_lines.size(),
		game_state.display_name,
	]
	bg_label.text = "背景：%s / 立绘：%s" % [line.get("bg", ""), line.get("portrait", "")]
	_apply_event_art(line)
	speaker_label.text = str(line.get("speaker", ""))
	text_label.text = str(line.get("text", ""))
	next_button.visible = true
	next_button.text = "继续" if active_ending_index + 1 < active_ending_lines.size() else "结束"
	_update_bag_cards()


func _show_ending_summary() -> void:
	if ending_summary_layer == null:
		return
	_hide_bottom_ui()
	var ending_id := str(active_ending.get("id", game_state.current_ending_id))
	ending_summary_title_label.text = _ending_title(ending_id)
	ending_summary_subtitle_label.text = "MVP-1 通关回顾"
	ending_summary_name_label.text = _memory_state_line(
		"名字",
		"mem_my_name",
		"世界还能叫出 %s。" % game_state.display_name,
		"名字已经留在森林里，世界只能称他为%s。" % game_state.display_name
	)
	ending_summary_reason_label.text = _memory_state_line(
		"出发理由",
		"mem_reason_to_depart",
		"莉娅的托付仍在背包中。",
		"莉娅的托付已经失落，胜利少了来处。"
	)
	ending_summary_bag_label.text = "保留的记忆：%s" % _memory_names(game_state.owned_memory_ids)
	ending_summary_lost_label.text = "丢失的记忆：%s" % _memory_names(game_state.discarded_memory_ids)
	ending_summary_stats_label.text = "通关状态：HP %d  ·  等级 %d  ·  金币 %d  ·  记忆碎片 %d" % [
		game_state.hp,
		game_state.level,
		game_state.gold,
		game_state.memory_fragment,
	]
	ending_summary_layer.visible = true


func _hide_ending_summary() -> void:
	if ending_summary_layer != null:
		ending_summary_layer.visible = false


func _ending_title(ending_id: String) -> String:
	match ending_id:
		"mvp_named_with_reason":
			return "结局：名字与理由仍在"
		"mvp_named_without_reason":
			return "结局：名字仍在，理由失落"
		"mvp_nameless_with_reason":
			return "结局：无名者仍记得理由"
		"mvp_nameless_without_reason":
			return "结局：没有名字，也没有来处"
		_:
			return "结局：未记录"


func _memory_state_line(label: String, memory_id: String, kept_text: String, lost_text: String) -> String:
	if game_state.has_memory(memory_id):
		return "%s：保留  ·  %s" % [label, kept_text]
	return "%s：失去  ·  %s" % [label, lost_text]


func _memory_names(memory_ids: Array[String]) -> String:
	if memory_ids.is_empty():
		return "无"
	var names: Array[String] = []
	for memory_id in memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		names.append(str(memory.get("name", memory_id)))
	return " / ".join(names)


func _update_battle_labels(event: Dictionary, result: Dictionary) -> void:
	_show_backpack_ui()
	name_label.text = "名字：%s"
	name_label.text = name_label.text % game_state.display_name
	status_label.text = "战斗结束  ·  HP：%d  ·  等级：%d  ·  金币：%d" % [
		game_state.hp,
		game_state.level,
		game_state.gold,
	]
	bg_label.text = "背景：%s / 敌人：%s" % [event.get("bg", ""), event.get("enemy_id", "")]
	_apply_event_art(event)
	speaker_label.text = "胜利" if bool(result.get("victory", false)) else "濒死"
	text_label.text = _compact_battle_log(result.get("logs", []))
	_update_bag_cards()
	_start_battle_stage(event, result)


func _apply_event_art(event: Dictionary) -> void:
	_set_texture_rect(bg_texture_rect, registry.get_art_asset(str(event.get("bg", "")), "background"))
	_set_texture_rect(portrait_texture_rect, registry.get_art_asset(str(event.get("portrait", "")), "portrait"))


func _clear_art_preview() -> void:
	_set_texture_rect(bg_texture_rect, {})
	_set_texture_rect(portrait_texture_rect, {})


func _set_texture_rect(texture_rect: TextureRect, art_asset: Dictionary) -> void:
	if texture_rect == null:
		return
	texture_rect.visible = false
	texture_rect.texture = null
	var path := str(art_asset.get("path", ""))
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	var image := Image.new()
	if image.load(path) != OK:
		return
	texture_rect.texture = ImageTexture.create_from_image(image)
	texture_rect.visible = true


func _apply_static_ui_art() -> void:
	_set_texture_rect(dialogue_texture_rect, registry.get_art_asset("ui_dialogue_box", "ui"))
	_set_texture_rect(nameplate_texture_rect, registry.get_art_asset("ui_nameplate", "ui"))
	_set_texture_rect(bag_panel_texture_rect, registry.get_art_asset("ui_bag_panel", "ui"))
	_set_texture_rect(travel_panel_texture_rect, registry.get_art_asset("ui_travel_stage_panel", "ui"))
	travel_walk_sheet_texture = _texture_from_asset(registry.get_art_asset("chibi_hero_walk_sheet", "chibi_sheet"))
	chibi_hero_attack_sheet_texture = _texture_from_asset(registry.get_art_asset("chibi_hero_attack_sheet", "chibi_sheet"))
	if travel_walk_sheet_texture != null:
		travel_chibi_texture_rect.texture = _sheet_frame_texture(travel_walk_sheet_texture, 0)
	if chibi_hero_attack_sheet_texture != null:
		battle_chibi_hero_texture_rect.texture = _sheet_frame_texture(chibi_hero_attack_sheet_texture, 0)


func _apply_button_texture_style(button: Button, _asset_id: String) -> void:
	# Generated choice art has uneven transparent edges when sliced. Keep the
	# asset registered, but use a clean themed button until UI art is redrawn.
	_apply_flat_button_style(button)


func _apply_flat_button_style(button: Button) -> void:
	var normal := _new_button_style(Color(0.08, 0.10, 0.10, 0.76), Color(0.63, 0.54, 0.32, 0.92))
	var hover := normal.duplicate()
	hover.bg_color = Color(0.13, 0.15, 0.14, 0.86)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.04, 0.05, 0.05, 0.9)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)


func _new_button_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 18
	style.content_margin_top = 8
	style.content_margin_right = 18
	style.content_margin_bottom = 8
	return style


func _on_viewport_size_changed() -> void:
	if ui_root != null:
		ui_root.size = _viewport_design_size()
	_layout_battle_stage()


func _viewport_design_size() -> Vector2:
	var size := get_viewport().get_visible_rect().size
	if size.x < 640.0 or size.y < 360.0:
		return Vector2(1280, 720)
	return size


func _update_header_status() -> void:
	var capacity := int(registry.balance.get("bag", {}).get("capacity_base", 4))
	if game_state.capacity() > 0:
		capacity = game_state.capacity()
	status_label.text = "%s  ·  HP：%d  ·  等级：%d  ·  记忆：%d/%d" % [
		game_state.display_name,
		game_state.hp,
		game_state.level,
		game_state.owned_memory_ids.size(),
		capacity,
	]


func _set_bottom_ui_mode(mode: String) -> void:
	var show_dialogue := mode == "dialogue"
	var show_backpack := mode == "backpack"
	if dialogue_panel != null:
		dialogue_panel.visible = show_dialogue
	if choices_box != null:
		choices_box.visible = show_dialogue
	if next_button != null:
		next_button.visible = show_dialogue and next_button.visible
	if quick_bag_bar != null:
		quick_bag_bar.visible = show_backpack


func _show_dialogue_ui() -> void:
	_set_bottom_ui_mode("dialogue")


func _show_backpack_ui() -> void:
	_clear_choices()
	if next_button != null:
		next_button.visible = false
	_set_bottom_ui_mode("backpack")


func _hide_bottom_ui() -> void:
	_clear_choices()
	if next_button != null:
		next_button.visible = false
	_set_bottom_ui_mode("")


func _layout_battle_stage() -> void:
	if battle_hero_texture_rect == null or battle_enemy_panel == null:
		return
	var size := _viewport_design_size()
	battle_hero_texture_rect.position = Vector2(size.x * 0.03, size.y * 0.10)
	battle_hero_texture_rect.size = Vector2(size.x * 0.18, size.y * 0.38)
	battle_chibi_hero_texture_rect.position = Vector2(size.x * 0.24, size.y * 0.27)
	battle_chibi_hero_texture_rect.size = Vector2(size.x * 0.18, size.y * 0.23)
	battle_chibi_enemy_texture_rect.position = Vector2(size.x * 0.61, size.y * 0.26)
	battle_chibi_enemy_texture_rect.size = Vector2(size.x * 0.18, size.y * 0.24)
	_layout_shadow_for(battle_chibi_hero_shadow, battle_chibi_hero_texture_rect, Vector2(0.52, 0.88), Vector2(0.38, 0.075))
	_layout_shadow_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, Vector2(0.50, 0.88), Vector2(0.48, 0.075))
	battle_enemy_panel.position = Vector2(size.x * 0.77, size.y * 0.08)
	battle_enemy_panel.size = Vector2(size.x * 0.18, size.y * 0.14)
	battle_status_label.position = Vector2(size.x * 0.31, size.y * 0.12)
	battle_status_label.size = Vector2(size.x * 0.38, size.y * 0.08)
	battle_slash_layer.position = Vector2(size.x * 0.48, size.y * 0.28)
	battle_slash_layer.size = Vector2(size.x * 0.24, size.y * 0.24)
	battle_float_label.position = Vector2(size.x * 0.56, size.y * 0.25)
	battle_float_label.size = Vector2(size.x * 0.29, size.y * 0.12)
	_update_battle_home_positions()


func _apply_modal_panel_style(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.055, 0.045, 0.88)
	style.border_color = Color(0.63, 0.48, 0.26, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)


func _apply_battle_enemy_style(panel: PanelContainer, bg_color := Color(0.06, 0.055, 0.045, 0.74), border_color := Color(0.60, 0.48, 0.26, 0.90), radius := 8) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)


func _apply_chibi_shadow_style(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	panel.add_theme_stylebox_override("panel", style)


func _texture_from_asset(art_asset: Dictionary) -> Texture2D:
	var path := str(art_asset.get("path", ""))
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _sheet_frame_texture(texture: Texture2D, frame: int, columns := 3, rows := 3) -> AtlasTexture:
	if texture == null:
		return null
	var frame_width := float(texture.get_width()) / float(columns)
	var frame_height := float(texture.get_height()) / float(rows)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2((frame % columns) * frame_width, int(frame / columns) * frame_height, frame_width, frame_height)
	return atlas


func _layout_shadow_for(shadow: Control, sprite: Control, center: Vector2, scale: Vector2) -> void:
	if shadow == null or sprite == null:
		return
	shadow.position = sprite.position + Vector2(sprite.size.x * (center.x - scale.x * 0.5), sprite.size.y * center.y)
	shadow.size = Vector2(sprite.size.x * scale.x, max(4.0, sprite.size.y * scale.y))


func _shadow_position_for(shadow: Control, sprite: Control, target_position: Vector2) -> Vector2:
	if shadow == null or sprite == null:
		return target_position
	return target_position + (shadow.position - sprite.position)


func _update_battle_chibi_shadows() -> void:
	_layout_shadow_for(battle_chibi_hero_shadow, battle_chibi_hero_texture_rect, Vector2(0.52, 0.88), Vector2(0.38, 0.075))
	_layout_shadow_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, Vector2(0.50, 0.88), Vector2(0.48, 0.075))
	if battle_chibi_hero_shadow != null:
		battle_chibi_hero_shadow.visible = battle_chibi_hero_texture_rect.visible
		battle_chibi_hero_shadow.modulate = Color(1.0, 1.0, 1.0, 0.22)
	if battle_chibi_enemy_shadow != null:
		battle_chibi_enemy_shadow.visible = battle_chibi_enemy_texture_rect.visible
		battle_chibi_enemy_shadow.modulate = Color(1.0, 1.0, 1.0, 0.20)


func _update_travel_stage_animation(delta: float) -> void:
	if travel_stage == null:
		return
	var should_show := _should_show_travel_stage()
	travel_stage.visible = should_show
	if not should_show:
		return
	if travel_walk_sheet_texture == null:
		return
	var speed_scale := 1.0 if run_controller.is_running else 0.35
	travel_frame_timer += delta * speed_scale
	if travel_frame_timer >= 0.12:
		travel_frame_timer = 0.0
		travel_frame_index = (travel_frame_index + 1) % 9
		travel_chibi_texture_rect.texture = _sheet_frame_texture(travel_walk_sheet_texture, travel_frame_index)
	var progress_ratio := 0.0
	if not run_controller.chapter_id.is_empty():
		var distance := _chapter_distance_for(run_controller.chapter_id)
		if distance > 0.0:
			progress_ratio = clamp(run_controller.progress / distance, 0.0, 1.0)
	var time := Time.get_ticks_msec() / 1000.0
	var drift := sin(time * 5.5) * 0.010
	var bob := sin(time * 12.0) * 0.010
	var path_offset := (progress_ratio - 0.5) * 0.16
	travel_chibi_texture_rect.anchor_left = 0.40 + path_offset + drift
	travel_chibi_texture_rect.anchor_right = travel_chibi_texture_rect.anchor_left + 0.20
	travel_chibi_texture_rect.anchor_top = travel_chibi_base_top + bob
	travel_chibi_texture_rect.anchor_bottom = 0.86 + bob
	travel_chibi_shadow.anchor_left = travel_chibi_texture_rect.anchor_left + 0.055
	travel_chibi_shadow.anchor_right = travel_chibi_texture_rect.anchor_left + 0.155
	travel_chibi_shadow.anchor_top = 0.81
	travel_chibi_shadow.anchor_bottom = 0.855
	travel_chibi_shadow.modulate = Color(1.0, 1.0, 1.0, 0.18 + abs(bob) * 4.0)


func _should_show_travel_stage() -> bool:
	if travel_stage == null or battle_stage == null:
		return false
	if battle_stage.visible or (ending_summary_layer != null and ending_summary_layer.visible):
		return false
	if not active_ending_lines.is_empty():
		return false
	return run_controller.chapter_id == "forest" and not run_controller.chapter_id.is_empty()


func _start_battle_stage(event: Dictionary, result: Dictionary) -> void:
	if battle_stage == null:
		return
	battle_animation_generation += 1
	_layout_battle_stage()
	battle_stage.visible = true
	battle_pressure_rect.visible = false
	battle_pressure_rect.color = Color(0.12, 0.02, 0.03, 0.0)
	battle_status_label.text = "战斗开始"
	_set_texture_rect(battle_hero_texture_rect, registry.get_art_asset("hero_default", "portrait"))
	battle_hero_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.40)
	if chibi_hero_attack_sheet_texture != null:
		battle_chibi_hero_texture_rect.texture = _sheet_frame_texture(chibi_hero_attack_sheet_texture, 0)
	battle_chibi_hero_texture_rect.visible = battle_chibi_hero_texture_rect.texture != null
	var enemy_name := _battle_enemy_name(event, result)
	battle_enemy_name_label.text = enemy_name
	_apply_battle_enemy_identity(_battle_enemy_id(event, result), [])
	_update_enemy_hp_display(1, 1)
	battle_float_label.visible = false
	battle_slash_layer.visible = false
	_update_battle_home_positions()
	battle_hero_texture_rect.position = battle_hero_home
	battle_chibi_hero_texture_rect.position = battle_chibi_hero_home
	battle_chibi_enemy_texture_rect.position = battle_chibi_enemy_home
	battle_enemy_panel.position = battle_enemy_home
	_update_battle_chibi_shadows()


func _play_battle_result_then_resume(result: Dictionary) -> void:
	var generation := battle_animation_generation
	await _play_battle_timeline(result.get("timeline", []), generation)
	if generation != battle_animation_generation:
		return
	run_controller.resume()


func _play_battle_timeline(events, generation: int) -> void:
	if typeof(events) != TYPE_ARRAY or events.is_empty():
		await get_tree().create_timer(0.45).timeout
		if generation == battle_animation_generation:
			await _finish_battle_stage()
		return
	var played := 0
	for event in events:
		if generation != battle_animation_generation:
			return
		if typeof(event) != TYPE_DICTIONARY:
			continue
		await _play_battle_step(event)
		played += 1
		if played >= 16:
			break
	await get_tree().create_timer(0.28).timeout
	if generation == battle_animation_generation:
		await _finish_battle_stage()


func _play_battle_step(event: Dictionary) -> void:
	var event_type := str(event.get("type", ""))
	if event_type == "enemy_appear":
		battle_enemy_name_label.text = str(event.get("enemy_name", "敌人"))
		_apply_battle_enemy_identity(str(event.get("enemy_id", "")), _string_array_from_variant(event.get("enemy_tags", [])))
		_update_enemy_hp_display(int(event.get("enemy_hp", 1)), int(event.get("enemy_max_hp", 1)))
		battle_status_label.text = "遭遇：%s" % battle_enemy_name_label.text
		battle_enemy_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
		if _tags_have(event.get("enemy_tags", []), "boss"):
			await _animate_boss_appear()
		var tween := create_tween()
		tween.tween_property(battle_enemy_panel, "modulate", Color.WHITE, 0.18)
		await tween.finished
	elif event_type == "player_attack":
		await _animate_player_attack(event)
	elif event_type == "enemy_attack":
		await _animate_enemy_attack(event)
	elif event_type == "enemy_defeated":
		battle_status_label.text = "%s 被击败" % str(event.get("enemy_name", "敌人"))
		var tween := create_tween()
		tween.tween_property(battle_enemy_panel, "modulate", Color(1.0, 1.0, 1.0, 0.25), 0.22)
		await tween.finished
	elif event_type == "memory_heal":
		await _animate_battle_notice("恢复 +%d" % int(event.get("amount", 0)), Color(0.55, 1.0, 0.68))
	elif event_type == "enemy_charge" or event_type == "enemy_guard" or event_type == "boss_pressure":
		if event_type == "boss_pressure":
			await _animate_boss_pressure(str(event.get("message", "")))
		else:
			await _animate_battle_notice(str(event.get("message", "")), Color(0.98, 0.82, 0.48))
	elif event_type == "player_near_death" or event_type == "revive":
		await _animate_battle_notice("濒死回退", Color(1.0, 0.45, 0.42))
	else:
		await get_tree().create_timer(0.1).timeout


func _animate_player_attack(event: Dictionary) -> void:
	battle_status_label.text = "勇者挥剑"
	var lunge_target := battle_chibi_hero_home + Vector2(96, -6)
	var out := create_tween()
	out.set_parallel(true)
	out.tween_property(battle_chibi_hero_texture_rect, "position", lunge_target, 0.12)
	out.tween_property(battle_chibi_hero_shadow, "position", _shadow_position_for(battle_chibi_hero_shadow, battle_chibi_hero_texture_rect, lunge_target), 0.12)
	out.tween_property(battle_chibi_hero_shadow, "modulate", Color(1.0, 1.0, 1.0, 0.30), 0.12)
	out.tween_property(battle_chibi_hero_texture_rect, "scale", Vector2(1.08, 1.08), 0.12)
	await out.finished
	await _play_chibi_attack_effect()
	_show_damage_text("-%d%s" % [
		int(event.get("damage", 0)),
		" 暴击" if bool(event.get("crit", false)) else "",
	], Color(1.0, 0.70, 0.36))
	_update_enemy_hp_display(int(event.get("enemy_hp", 0)), int(event.get("enemy_max_hp", 1)))
	await _play_slash_effect()
	var hit := create_tween()
	hit.set_parallel(true)
	hit.tween_property(battle_chibi_enemy_texture_rect, "position", battle_chibi_enemy_home + Vector2(16, 0), 0.06)
	hit.tween_property(battle_chibi_enemy_shadow, "position", _shadow_position_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, battle_chibi_enemy_home + Vector2(16, 0)), 0.06)
	hit.tween_property(battle_chibi_enemy_texture_rect, "modulate", Color(1.0, 0.65, 0.58, 1.0), 0.06)
	await hit.finished
	var back := create_tween()
	back.set_parallel(true)
	back.tween_property(battle_chibi_hero_texture_rect, "position", battle_chibi_hero_home, 0.16)
	back.tween_property(battle_chibi_hero_shadow, "position", _shadow_position_for(battle_chibi_hero_shadow, battle_chibi_hero_texture_rect, battle_chibi_hero_home), 0.16)
	back.tween_property(battle_chibi_hero_shadow, "modulate", Color(1.0, 1.0, 1.0, 0.22), 0.16)
	back.tween_property(battle_chibi_hero_texture_rect, "scale", Vector2.ONE, 0.16)
	back.tween_property(battle_chibi_enemy_texture_rect, "position", battle_chibi_enemy_home, 0.10)
	back.tween_property(battle_chibi_enemy_shadow, "position", _shadow_position_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, battle_chibi_enemy_home), 0.10)
	back.tween_property(battle_chibi_enemy_texture_rect, "modulate", Color.WHITE, 0.10)
	await back.finished


func _animate_enemy_attack(event: Dictionary) -> void:
	battle_status_label.text = "%s 反击" % str(event.get("enemy_name", "敌人"))
	var out := create_tween()
	out.set_parallel(true)
	out.tween_property(battle_chibi_enemy_texture_rect, "position", battle_chibi_enemy_home + Vector2(-56, 0), 0.10)
	out.tween_property(battle_chibi_enemy_shadow, "position", _shadow_position_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, battle_chibi_enemy_home + Vector2(-56, 0)), 0.10)
	await out.finished
	_show_damage_text("勇者 -%d" % int(event.get("damage", 0)), Color(1.0, 0.48, 0.43), Vector2(0.10, 0.30))
	var hit := create_tween()
	hit.set_parallel(true)
	hit.tween_property(battle_chibi_hero_texture_rect, "modulate", Color(1.0, 0.66, 0.62, 1.0), 0.06)
	hit.tween_property(battle_chibi_hero_texture_rect, "position", battle_chibi_hero_home + Vector2(-14, 0), 0.06)
	hit.tween_property(battle_chibi_hero_shadow, "position", _shadow_position_for(battle_chibi_hero_shadow, battle_chibi_hero_texture_rect, battle_chibi_hero_home + Vector2(-14, 0)), 0.06)
	await hit.finished
	var back := create_tween()
	back.set_parallel(true)
	back.tween_property(battle_chibi_enemy_texture_rect, "position", battle_chibi_enemy_home, 0.12)
	back.tween_property(battle_chibi_enemy_shadow, "position", _shadow_position_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, battle_chibi_enemy_home), 0.12)
	back.tween_property(battle_chibi_hero_texture_rect, "modulate", Color.WHITE, 0.10)
	back.tween_property(battle_chibi_hero_texture_rect, "position", battle_chibi_hero_home, 0.10)
	back.tween_property(battle_chibi_hero_shadow, "position", _shadow_position_for(battle_chibi_hero_shadow, battle_chibi_hero_texture_rect, battle_chibi_hero_home), 0.10)
	await back.finished


func _animate_boss_appear() -> void:
	battle_pressure_rect.visible = true
	battle_pressure_rect.color = Color(0.20, 0.02, 0.04, 0.0)
	battle_status_label.text = "名字被拉向弓弦"
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(battle_pressure_rect, "color", Color(0.20, 0.02, 0.04, 0.28), 0.22)
	tween.tween_property(battle_enemy_panel, "scale", Vector2(1.05, 1.05), 0.18)
	tween.tween_property(battle_chibi_enemy_texture_rect, "scale", Vector2(1.08, 1.08), 0.18)
	tween.tween_property(battle_chibi_enemy_shadow, "scale", Vector2(1.12, 1.0), 0.18)
	await tween.finished
	var settle := create_tween()
	settle.set_parallel(true)
	settle.tween_property(battle_enemy_panel, "scale", Vector2.ONE, 0.12)
	settle.tween_property(battle_chibi_enemy_texture_rect, "scale", Vector2.ONE, 0.12)
	settle.tween_property(battle_chibi_enemy_shadow, "scale", Vector2.ONE, 0.12)
	await settle.finished


func _animate_boss_pressure(message: String) -> void:
	if message.strip_edges().is_empty():
		message = "忘名猎人的弓弦正在寻找一个名字。"
	battle_pressure_rect.visible = true
	battle_pressure_rect.color = Color(0.30, 0.02, 0.06, 0.20)
	await _animate_battle_notice(message, Color(1.0, 0.55, 0.58))
	var shake := create_tween()
	shake.set_parallel(true)
	shake.tween_property(battle_enemy_panel, "position", battle_enemy_home + Vector2(-10, 0), 0.05)
	shake.tween_property(battle_chibi_enemy_texture_rect, "position", battle_chibi_enemy_home + Vector2(-14, 0), 0.05)
	shake.tween_property(battle_chibi_enemy_shadow, "position", _shadow_position_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, battle_chibi_enemy_home + Vector2(-14, 0)), 0.05)
	shake.tween_property(battle_pressure_rect, "color", Color(0.30, 0.02, 0.06, 0.34), 0.05)
	await shake.finished
	var back := create_tween()
	back.set_parallel(true)
	back.tween_property(battle_enemy_panel, "position", battle_enemy_home, 0.08)
	back.tween_property(battle_chibi_enemy_texture_rect, "position", battle_chibi_enemy_home, 0.08)
	back.tween_property(battle_chibi_enemy_shadow, "position", _shadow_position_for(battle_chibi_enemy_shadow, battle_chibi_enemy_texture_rect, battle_chibi_enemy_home), 0.08)
	back.tween_property(battle_pressure_rect, "color", Color(0.20, 0.02, 0.04, 0.24), 0.12)
	await back.finished


func _animate_battle_notice(message: String, color: Color) -> void:
	if message.strip_edges().is_empty():
		await get_tree().create_timer(0.08).timeout
		return
	battle_status_label.text = message
	battle_status_label.modulate = color
	var tween := create_tween()
	tween.tween_property(battle_status_label, "scale", Vector2(1.08, 1.08), 0.08)
	tween.tween_property(battle_status_label, "scale", Vector2.ONE, 0.12)
	await tween.finished
	battle_status_label.modulate = Color.WHITE


func _play_slash_effect() -> void:
	if battle_slash_layer == null:
		return
	for child in battle_slash_layer.get_children():
		child.queue_free()
	battle_slash_layer.visible = true
	battle_slash_layer.modulate = Color.WHITE
	var main_slash := _new_slash_line(7.0, Color(1.0, 1.0, 1.0, 0.96))
	var glow_slash := _new_slash_line(18.0, Color(0.78, 0.88, 1.0, 0.24))
	var spark := _new_slash_line(3.0, Color(1.0, 0.92, 0.70, 0.78), Vector2(0.26, 0.72), Vector2(0.92, 0.18))
	battle_slash_layer.add_child(glow_slash)
	battle_slash_layer.add_child(main_slash)
	battle_slash_layer.add_child(spark)
	battle_slash_layer.scale = Vector2(0.74, 0.74)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(battle_slash_layer, "scale", Vector2(1.08, 1.08), 0.11)
	tween.tween_property(battle_slash_layer, "modulate", Color(1, 1, 1, 0), 0.18).set_delay(0.06)
	await tween.finished
	battle_slash_layer.visible = false


func _new_slash_line(width: float, color: Color, from := Vector2(0.14, 0.82), to := Vector2(0.86, 0.12)) -> Line2D:
	var line := Line2D.new()
	var size := battle_slash_layer.size
	line.points = PackedVector2Array([
		Vector2(size.x * from.x, size.y * from.y),
		Vector2(size.x * to.x, size.y * to.y),
	])
	line.width = width
	line.default_color = color
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	return line


func _play_chibi_attack_effect() -> void:
	if chibi_hero_attack_sheet_texture == null:
		return
	for frame in range(9):
		battle_chibi_hero_texture_rect.texture = _sheet_frame_texture(chibi_hero_attack_sheet_texture, frame)
		await get_tree().create_timer(0.035).timeout
	if chibi_hero_attack_sheet_texture != null:
		battle_chibi_hero_texture_rect.texture = _sheet_frame_texture(chibi_hero_attack_sheet_texture, 0)


func _show_damage_text(text: String, color: Color, anchor := Vector2(0.56, 0.22)) -> void:
	var size := _viewport_design_size()
	battle_float_label.position = Vector2(size.x * anchor.x, size.y * anchor.y)
	battle_float_label.size = Vector2(size.x * 0.29, size.y * 0.12)
	battle_float_label.text = text
	battle_float_label.add_theme_color_override("font_color", color)
	battle_float_label.visible = true
	battle_float_label.modulate = Color.WHITE
	var start_position := battle_float_label.position
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(battle_float_label, "position", start_position + Vector2(0, -26), 0.28)
	tween.tween_property(battle_float_label, "modulate", Color(1, 1, 1, 0), 0.28)
	tween.finished.connect(func(): battle_float_label.visible = false)


func _update_enemy_hp_display(current_hp: int, max_hp: int) -> void:
	max_hp = max(1, max_hp)
	current_hp = clampi(current_hp, 0, max_hp)
	battle_enemy_hp_bar.max_value = max_hp
	battle_enemy_hp_bar.value = current_hp
	battle_enemy_hp_label.text = "HP %d / %d" % [current_hp, max_hp]


func _finish_battle_stage() -> void:
	if battle_stage == null:
		return
	battle_status_label.text = "战斗结束"
	battle_slash_layer.visible = false
	battle_float_label.visible = false
	battle_pressure_rect.visible = false
	battle_pressure_rect.color = Color(0.12, 0.02, 0.03, 0.0)
	var tween := create_tween()
	tween.tween_property(battle_stage, "modulate", Color(1, 1, 1, 0), 0.18)
	await tween.finished
	battle_stage.visible = false
	battle_stage.modulate = Color.WHITE
	battle_enemy_panel.modulate = Color.WHITE
	battle_hero_texture_rect.modulate = Color.WHITE
	battle_chibi_hero_texture_rect.modulate = Color.WHITE
	battle_chibi_enemy_texture_rect.modulate = Color.WHITE
	battle_pressure_rect.visible = false
	battle_pressure_rect.color = Color(0.12, 0.02, 0.03, 0.0)
	battle_hero_texture_rect.position = battle_hero_home
	battle_chibi_hero_texture_rect.position = battle_chibi_hero_home
	battle_chibi_enemy_texture_rect.position = battle_chibi_enemy_home
	battle_enemy_panel.position = battle_enemy_home
	battle_hero_texture_rect.scale = Vector2.ONE
	battle_chibi_hero_texture_rect.scale = Vector2.ONE
	battle_chibi_enemy_texture_rect.scale = Vector2.ONE
	battle_chibi_hero_shadow.scale = Vector2.ONE
	battle_chibi_enemy_shadow.scale = Vector2.ONE
	battle_enemy_panel.scale = Vector2.ONE
	_update_battle_chibi_shadows()


func _cancel_battle_animation() -> void:
	battle_animation_generation += 1
	if battle_stage == null:
		return
	battle_stage.visible = false
	battle_stage.modulate = Color.WHITE
	battle_slash_layer.visible = false
	battle_float_label.visible = false
	battle_pressure_rect.visible = false
	battle_pressure_rect.color = Color(0.12, 0.02, 0.03, 0.0)
	battle_enemy_panel.modulate = Color.WHITE
	battle_hero_texture_rect.modulate = Color.WHITE
	battle_chibi_hero_texture_rect.modulate = Color.WHITE
	battle_chibi_enemy_texture_rect.modulate = Color.WHITE
	battle_hero_texture_rect.position = battle_hero_home
	battle_chibi_hero_texture_rect.position = battle_chibi_hero_home
	battle_chibi_enemy_texture_rect.position = battle_chibi_enemy_home
	battle_enemy_panel.position = battle_enemy_home
	battle_hero_texture_rect.scale = Vector2.ONE
	battle_chibi_hero_texture_rect.scale = Vector2.ONE
	battle_chibi_enemy_texture_rect.scale = Vector2.ONE
	battle_chibi_hero_shadow.scale = Vector2.ONE
	battle_chibi_enemy_shadow.scale = Vector2.ONE
	battle_enemy_panel.scale = Vector2.ONE
	_update_battle_chibi_shadows()


func _update_battle_home_positions() -> void:
	if battle_hero_texture_rect == null or battle_enemy_panel == null:
		return
	battle_hero_home = battle_hero_texture_rect.position
	battle_enemy_home = battle_enemy_panel.position
	battle_chibi_hero_home = battle_chibi_hero_texture_rect.position
	battle_chibi_enemy_home = battle_chibi_enemy_texture_rect.position


func _battle_enemy_name(event: Dictionary, result: Dictionary) -> String:
	var ids = result.get("enemy_ids", [])
	if typeof(ids) == TYPE_ARRAY and not ids.is_empty():
		var enemy: Dictionary = registry.enemies.get(str(ids[0]), {})
		return str(enemy.get("log_name", enemy.get("name", ids[0])))
	var enemy_id := str(event.get("enemy_id", ""))
	var enemy: Dictionary = registry.enemies.get(enemy_id, {})
	return str(enemy.get("log_name", enemy.get("name", enemy_id)))


func _battle_enemy_id(event: Dictionary, result: Dictionary) -> String:
	var ids = result.get("enemy_ids", [])
	if typeof(ids) == TYPE_ARRAY and not ids.is_empty():
		return str(ids[0])
	var raw := str(event.get("enemy_id", ""))
	if raw.contains(","):
		return raw.split(",", false, 1)[0].strip_edges()
	return raw


func _apply_battle_enemy_identity(enemy_id: String, tags: Array[String]) -> void:
	if tags.is_empty() and not enemy_id.is_empty():
		var enemy: Dictionary = registry.enemies.get(enemy_id, {})
		tags = _string_array_from_variant(enemy.get("tags", []))
	var profile := _battle_enemy_profile(enemy_id, tags)
	var chibi_enemy_texture := _chibi_enemy_texture(enemy_id)
	battle_chibi_enemy_texture_rect.texture = chibi_enemy_texture
	battle_chibi_enemy_texture_rect.visible = chibi_enemy_texture != null
	battle_chibi_enemy_shadow.visible = chibi_enemy_texture != null
	battle_enemy_texture_rect.texture = null
	battle_enemy_texture_rect.visible = false
	battle_enemy_symbol_label.text = str(profile.get("symbol", "◇"))
	battle_enemy_symbol_label.visible = chibi_enemy_texture == null
	battle_enemy_symbol_label.add_theme_font_size_override("font_size", int(profile.get("symbol_size", 74)))
	battle_enemy_symbol_label.add_theme_color_override("font_color", profile.get("symbol_color", Color(0.18, 0.18, 0.18, 0.92)))
	battle_enemy_type_label.text = str(profile.get("type_text", "空壳"))
	battle_enemy_type_label.add_theme_color_override("font_color", profile.get("type_color", Color(0.67, 0.62, 0.50)))
	_apply_battle_enemy_style(battle_enemy_panel, profile.get("panel_bg", Color(0.06, 0.055, 0.045, 0.74)), profile.get("panel_border", Color(0.60, 0.48, 0.26, 0.90)))


func _chibi_enemy_texture(enemy_id: String) -> Texture2D:
	var asset_id := "chibi_%s" % enemy_id
	if enemy_id == "boss_nameless_hunter":
		asset_id = "chibi_boss_nameless_hunter"
	return _texture_from_asset(registry.get_art_asset(asset_id, "chibi_unit"))


func _battle_enemy_profile(enemy_id: String, tags: Array[String]) -> Dictionary:
	if tags.has("boss"):
		return {
			"symbol": "弓",
			"symbol_size": 72,
			"symbol_color": Color(0.78, 0.12, 0.18, 0.96),
			"type_text": "Boss / 无名 / 空壳",
			"type_color": Color(1.0, 0.52, 0.50),
			"panel_bg": Color(0.10, 0.035, 0.035, 0.82),
			"panel_border": Color(0.86, 0.28, 0.25, 0.96),
		}
	if enemy_id == "enemy_nameless_deer" or tags.has("nameless"):
		return {
			"symbol": "鹿",
			"symbol_size": 70,
			"symbol_color": Color(0.54, 0.58, 0.63, 0.94),
			"type_text": "无名",
			"type_color": Color(0.78, 0.82, 0.90),
			"panel_bg": Color(0.045, 0.055, 0.065, 0.76),
			"panel_border": Color(0.52, 0.60, 0.74, 0.92),
		}
	if enemy_id == "enemy_hollow_warden" or tags.has("silent"):
		return {
			"symbol": "守",
			"symbol_size": 70,
			"symbol_color": Color(0.38, 0.42, 0.36, 0.96),
			"type_text": "空壳 / 沉默",
			"type_color": Color(0.70, 0.72, 0.62),
			"panel_bg": Color(0.045, 0.060, 0.048, 0.78),
			"panel_border": Color(0.50, 0.58, 0.40, 0.92),
		}
	return {
		"symbol": "狼",
		"symbol_size": 70,
		"symbol_color": Color(0.22, 0.22, 0.20, 0.96),
		"type_text": "空壳",
		"type_color": Color(0.72, 0.66, 0.54),
		"panel_bg": Color(0.06, 0.055, 0.045, 0.74),
		"panel_border": Color(0.60, 0.48, 0.26, 0.90),
	}


func _string_array_from_variant(values) -> Array[String]:
	var result: Array[String] = []
	if typeof(values) != TYPE_ARRAY:
		return result
	for value in values:
		result.append(str(value))
	return result


func _tags_have(values, tag: String) -> bool:
	return _string_array_from_variant(values).has(tag)


func _compact_battle_log(values) -> String:
	if typeof(values) != TYPE_ARRAY:
		return ""
	var lines: Array[String] = []
	for value in values:
		lines.append(str(value))
	if lines.size() <= 2:
		return "\n".join(lines)
	var summary: Array[String] = []
	for line in lines:
		if line.contains("被击败") or line.contains("濒死"):
			summary.append(line)
			break
	for line in lines:
		if line.contains("战斗奖励"):
			summary.append(line)
			break
	if summary.size() >= 2:
		return "\n".join(summary.slice(0, 2))
	return "\n".join(lines.slice(max(0, lines.size() - 2), lines.size()))
