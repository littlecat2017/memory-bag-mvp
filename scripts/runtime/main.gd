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

var name_label: Label
var status_label: Label
var progress_label: Label
var bg_label: Label
var bg_texture_rect: TextureRect
var portrait_texture_rect: TextureRect
var dialogue_texture_rect: TextureRect
var nameplate_texture_rect: TextureRect
var bag_panel_texture_rect: TextureRect
var speaker_label: Label
var text_label: Label
var bag_grid: GridContainer
var memory_cards: Array[PanelContainer] = []
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

	var dialogue_panel := Control.new()
	dialogue_panel.anchor_left = 0.04
	dialogue_panel.anchor_top = 0.67
	dialogue_panel.anchor_right = 0.96
	dialogue_panel.anchor_bottom = 0.96
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
	dialogue_margin.add_theme_constant_override("margin_top", 48)
	dialogue_margin.add_theme_constant_override("margin_right", 44)
	dialogue_margin.add_theme_constant_override("margin_bottom", 24)
	dialogue_panel.add_child(dialogue_margin)

	var dialogue_box := VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 8)
	dialogue_margin.add_child(dialogue_box)

	var speaker_row := Control.new()
	speaker_row.custom_minimum_size = Vector2(0, 42)
	dialogue_box.add_child(speaker_row)

	nameplate_texture_rect = TextureRect.new()
	nameplate_texture_rect.anchor_left = 0.0
	nameplate_texture_rect.anchor_top = 0.0
	nameplate_texture_rect.anchor_right = 0.0
	nameplate_texture_rect.anchor_bottom = 0.0
	nameplate_texture_rect.offset_left = -18
	nameplate_texture_rect.offset_top = -16
	nameplate_texture_rect.offset_right = 250
	nameplate_texture_rect.offset_bottom = 48
	nameplate_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nameplate_texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	speaker_row.add_child(nameplate_texture_rect)

	speaker_label = Label.new()
	speaker_label.offset_left = 18
	speaker_label.offset_top = -2
	speaker_label.offset_right = 235
	speaker_label.offset_bottom = 40
	speaker_label.add_theme_font_size_override("font_size", 23)
	speaker_label.add_theme_color_override("font_color", Color(0.16, 0.10, 0.06))
	speaker_row.add_child(speaker_label)

	text_label = Label.new()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("font_size", 25)
	text_label.add_theme_color_override("font_color", Color(0.93, 0.89, 0.78))
	dialogue_box.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.anchor_left = 0.15
	choices_box.anchor_top = 0.34
	choices_box.anchor_right = 0.85
	choices_box.anchor_bottom = 0.54
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

	next_button = Button.new()
	next_button.text = "继续"
	next_button.anchor_left = 0.84
	next_button.anchor_top = 0.90
	next_button.anchor_right = 0.94
	next_button.anchor_bottom = 0.96
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

	_apply_static_ui_art()
	_apply_button_texture_style(next_button, "ui_choice_button")


func _show_load_error() -> void:
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
	_update_static_labels(event)
	_rebuild_choices(event)
	if game_state.has_pending_memory():
		next_button.visible = false


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
	next_button.visible = false
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
			card.set_memory(memory, registry.get_art_asset_for_memory(memory_id))
		else:
			card.set_empty(index + 1)


func _rebuild_choices(event: Dictionary) -> void:
	_clear_choices()
	var is_choice := str(event.get("type", "")) == "choice"
	next_button.visible = not is_choice
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
	_clear_choices()
	next_button.visible = false
	var result := battle_runner.run_event(event)
	_update_battle_labels(event, result)
	run_controller.resume()


func _on_memory_replacement_requested(memory_id: String, _next_event_id: String) -> void:
	_clear_choices()
	next_button.visible = false
	replacement_panel.visible = true
	pending_core_discard_id = ""
	replacement_confirm_box.visible = false
	var memory: Dictionary = registry.memories.get(memory_id, {})
	replacement_new_card.set_memory(memory, registry.get_art_asset_for_memory(memory_id))
	_rebuild_replacement_options()


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
	_accept_pending_by_discard(pending_core_discard_id)


func _on_cancel_core_discard_pressed() -> void:
	pending_core_discard_id = ""
	replacement_confirm_box.visible = false


func _on_decline_pending_memory_pressed() -> void:
	game_state.decline_pending_memory()
	replacement_panel.visible = false
	script_player.finish_memory_replacement()
	_update_bag_cards()


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
	run_controller.pause()
	active_script_node_id = ""
	active_ending = ending_runner.evaluate_mvp_ending()
	active_ending_lines = active_ending.get("lines", [])
	active_ending_index = -1
	if active_ending_lines.is_empty():
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
		_update_header_status()
		speaker_label.text = "系统"
		text_label.text = "MVP 到此结束。"
		next_button.visible = false
		active_ending_lines.clear()
		_update_bag_cards()
		return
	var line: Dictionary = active_ending_lines[active_ending_index]
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


func _update_battle_labels(event: Dictionary, result: Dictionary) -> void:
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
	text_label.text = "\n".join(result.get("logs", []))
	_update_bag_cards()


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
