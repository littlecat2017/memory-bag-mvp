extends Control

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")
const MemoryCardViewScript := preload("res://scripts/ui/memory_card_view.gd")

var registry = DataRegistryScript.new()
var game_state = GameStateScript.new()
var script_player = ScriptPlayerScript.new()

var name_label: Label
var status_label: Label
var bg_label: Label
var speaker_label: Label
var text_label: Label
var bag_grid: GridContainer
var memory_cards: Array[PanelContainer] = []
var next_button: Button
var choices_box: VBoxContainer


func _ready() -> void:
	var ok := registry.load_all()
	print(registry.summary())
	for error in registry.validation_errors:
		push_error(error)
	_build_ui()
	if not ok:
		_show_load_error()
		return
	game_state.configure_from_balance(registry.balance)
	script_player.setup(registry, game_state)
	script_player.event_changed.connect(_on_event_changed)
	script_player.script_finished.connect(_on_script_finished)
	script_player.start("P0001")


func _build_ui() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 10)
	root.offset_left = 24
	root.offset_top = 18
	root.offset_right = -24
	root.offset_bottom = -18
	add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	root.add_child(header)

	name_label = Label.new()
	name_label.custom_minimum_size = Vector2(180, 28)
	header.add_child(name_label)

	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(status_label)

	bg_label = Label.new()
	root.add_child(bg_label)

	var dialogue_panel := PanelContainer.new()
	dialogue_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(dialogue_panel)

	var dialogue_margin := MarginContainer.new()
	dialogue_margin.add_theme_constant_override("margin_left", 18)
	dialogue_margin.add_theme_constant_override("margin_top", 18)
	dialogue_margin.add_theme_constant_override("margin_right", 18)
	dialogue_margin.add_theme_constant_override("margin_bottom", 18)
	dialogue_panel.add_child(dialogue_margin)

	var dialogue_box := VBoxContainer.new()
	dialogue_box.add_theme_constant_override("separation", 12)
	dialogue_margin.add_child(dialogue_box)

	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 22)
	dialogue_box.add_child(speaker_label)

	text_label = Label.new()
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("font_size", 24)
	dialogue_box.add_child(text_label)

	choices_box = VBoxContainer.new()
	choices_box.add_theme_constant_override("separation", 8)
	dialogue_box.add_child(choices_box)

	var bag_title := Label.new()
	bag_title.text = "记忆背包"
	bag_title.add_theme_font_size_override("font_size", 18)
	root.add_child(bag_title)

	bag_grid = GridContainer.new()
	bag_grid.columns = 4
	bag_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(bag_grid)
	for index in range(4):
		var card = MemoryCardViewScript.new()
		card.set_empty(index + 1)
		memory_cards.append(card)
		bag_grid.add_child(card)

	next_button = Button.new()
	next_button.text = "继续"
	next_button.pressed.connect(_on_next_pressed)
	root.add_child(next_button)


func _show_load_error() -> void:
	name_label.text = "记忆背包"
	status_label.text = "数据校验失败"
	bg_label.text = ""
	speaker_label.text = "系统"
	text_label.text = "\n".join(registry.validation_errors)
	_update_bag_cards()
	next_button.disabled = true


func _on_event_changed(event: Dictionary) -> void:
	_update_static_labels(event)
	_rebuild_choices(event)


func _on_script_finished() -> void:
	status_label.text = "序章脚本播放完成"
	bg_label.text = ""
	speaker_label.text = "系统"
	text_label.text = "已播放到当前脚本段末尾。"
	_clear_choices()
	next_button.visible = false
	_update_bag_cards()


func _update_static_labels(event: Dictionary) -> void:
	name_label.text = "名字：%s" % game_state.display_name
	status_label.text = "事件：%s / 类型：%s" % [event.get("id", ""), event.get("type", "")]
	bg_label.text = "背景：%s / 立绘：%s" % [event.get("bg", ""), event.get("portrait", "")]
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
			card.set_memory(memory)
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
		button.pressed.connect(_on_choice_pressed.bind(index))
		choices_box.add_child(button)


func _clear_choices() -> void:
	for child in choices_box.get_children():
		child.queue_free()


func _on_next_pressed() -> void:
	script_player.advance()


func _on_choice_pressed(index: int) -> void:
	script_player.select_choice(index)
