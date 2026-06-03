extends PanelContainer

signal memory_dropped(data: Dictionary, target_kind: String, target_index: int)

const CARD_TEXT := Color(0.30, 0.20, 0.10)
const CARD_TEXT_MUTED := Color(0.48, 0.36, 0.22)
const CARD_TEXT_DANGER := Color(0.68, 0.20, 0.16)
const CARD_TEXT_DANGER_MUTED := Color(0.56, 0.32, 0.22)
const CARD_TEXT_FOUND := Color(0.72, 0.92, 0.94)
const CARD_TEXT_FOUND_MUTED := Color(0.58, 0.78, 0.78)

var title_label: Label
var tags_label: Label
var effect_label: Label
var relation_label: Label
var obligation_label: Label
var loss_hint_label: Label
var icon_texture_rect: TextureRect
var margin_container: MarginContainer
var content_box: VBoxContainer
var memory_id := ""
var slot_index := -1
var target_kind := "card"
var compact_mode := false
var zone_kind := ""


func _init() -> void:
	custom_minimum_size = Vector2(260, 132)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	_build()


func set_empty(slot_index: int) -> void:
	memory_id = ""
	zone_kind = ""
	self.slot_index = slot_index - 1
	icon_texture_rect.visible = false
	icon_texture_rect.texture = null
	title_label.text = "空记忆格 %d" % slot_index
	tags_label.text = "标签：-"
	effect_label.text = "效果：-"
	relation_label.text = "关系：-"
	obligation_label.text = "承诺：-"
	loss_hint_label.text = "丢弃提示：-"
	_apply_compact_visibility()
	_apply_panel_style()


func set_memory(memory: Dictionary, art_asset: Dictionary = {}, id := "") -> void:
	memory_id = id
	zone_kind = ""
	_apply_icon_asset(art_asset)
	title_label.text = str(memory.get("name", "未知记忆"))
	tags_label.text = "标签：%s" % _join_tags(memory.get("tags", []))
	effect_label.text = "效果：%s" % memory.get("effect_text", "")
	relation_label.text = "关系：%s / %s" % [
		memory.get("relation_target", ""),
		memory.get("relation_type", ""),
	]
	obligation_label.text = "承诺：%s" % memory.get("obligation", "")
	loss_hint_label.text = "丢弃提示：%s" % memory.get("ui_loss_hint", "")
	_apply_compact_visibility()
	_apply_panel_style()


func set_zone(title: String, subtitle: String, kind: String) -> void:
	memory_id = ""
	zone_kind = kind
	target_kind = kind
	icon_texture_rect.visible = false
	icon_texture_rect.texture = null
	title_label.text = title
	tags_label.text = subtitle
	effect_label.text = ""
	relation_label.text = ""
	obligation_label.text = ""
	loss_hint_label.text = ""
	_apply_compact_visibility()
	_apply_panel_style()


func set_compact(enabled: bool) -> void:
	compact_mode = enabled
	custom_minimum_size = Vector2(138, 86) if compact_mode else Vector2(260, 132)
	_apply_compact_visibility()
	_apply_panel_style()


func configure_drop_target(kind: String, index := -1) -> void:
	target_kind = kind
	slot_index = index


func has_required_memory_text() -> bool:
	return not title_label.text.is_empty() \
		and relation_label.text.find("关系：") == 0 \
		and obligation_label.text.find("承诺：") == 0 \
		and loss_hint_label.text.find("丢弃提示：") == 0


func _get_drag_data(_at_position: Vector2):
	if memory_id.is_empty():
		return null
	var preview := Label.new()
	preview.text = title_label.text
	preview.add_theme_font_size_override("font_size", 16)
	preview.add_theme_color_override("font_color", CARD_TEXT)
	set_drag_preview(preview)
	return {
		"memory_id": memory_id,
		"source_kind": target_kind,
		"source_index": slot_index,
	}


func _can_drop_data(_at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and str(data.get("memory_id", "")) != ""


func _drop_data(_at_position: Vector2, data) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	memory_dropped.emit(data, target_kind, slot_index)


func _build() -> void:
	margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_top", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	margin_container.add_theme_constant_override("margin_bottom", 10)
	add_child(margin_container)

	content_box = VBoxContainer.new()
	content_box.add_theme_constant_override("separation", 5)
	margin_container.add_child(content_box)

	title_label = _new_label(18)
	title_label.text = "空记忆格"
	content_box.add_child(title_label)

	icon_texture_rect = TextureRect.new()
	icon_texture_rect.custom_minimum_size = Vector2(46, 46)
	icon_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_texture_rect.visible = false
	content_box.add_child(icon_texture_rect)

	tags_label = _new_label(13)
	content_box.add_child(tags_label)

	effect_label = _new_label(12)
	content_box.add_child(effect_label)

	relation_label = _new_label(12)
	content_box.add_child(relation_label)

	obligation_label = _new_label(11)
	content_box.add_child(obligation_label)

	loss_hint_label = _new_label(11)
	content_box.add_child(loss_hint_label)
	_apply_panel_style()


func _new_label(font_size: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _apply_compact_visibility() -> void:
	if title_label == null:
		return
	var padding := 3 if compact_mode else 10
	var separation := 3 if compact_mode else 5
	margin_container.add_theme_constant_override("margin_left", padding)
	margin_container.add_theme_constant_override("margin_top", padding)
	margin_container.add_theme_constant_override("margin_right", padding)
	margin_container.add_theme_constant_override("margin_bottom", padding)
	content_box.add_theme_constant_override("separation", separation)
	icon_texture_rect.custom_minimum_size = Vector2(48, 48) if compact_mode else Vector2(46, 46)
	effect_label.visible = not compact_mode
	relation_label.visible = not compact_mode
	obligation_label.visible = not compact_mode
	loss_hint_label.visible = not compact_mode
	tags_label.visible = not compact_mode or not zone_kind.is_empty() or memory_id.is_empty()
	title_label.add_theme_font_size_override("font_size", 12 if compact_mode else 18)
	tags_label.add_theme_font_size_override("font_size", 10 if compact_mode else 13)
	if compact_mode:
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if zone_kind == "trash":
			title_label.add_theme_color_override("font_color", CARD_TEXT_DANGER)
			tags_label.add_theme_color_override("font_color", CARD_TEXT_DANGER_MUTED)
		elif zone_kind == "found":
			title_label.add_theme_color_override("font_color", CARD_TEXT_FOUND)
			tags_label.add_theme_color_override("font_color", CARD_TEXT_FOUND_MUTED)
		else:
			title_label.add_theme_color_override("font_color", CARD_TEXT)
			tags_label.add_theme_color_override("font_color", CARD_TEXT_MUTED)
	else:
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		icon_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_label.add_theme_color_override("font_color", CARD_TEXT)
		tags_label.add_theme_color_override("font_color", CARD_TEXT_MUTED)
	effect_label.add_theme_color_override("font_color", CARD_TEXT_MUTED)
	relation_label.add_theme_color_override("font_color", CARD_TEXT_MUTED)
	obligation_label.add_theme_color_override("font_color", CARD_TEXT_MUTED)
	loss_hint_label.add_theme_color_override("font_color", CARD_TEXT_MUTED)


func _apply_panel_style() -> void:
	var style := StyleBoxEmpty.new()
	if compact_mode:
		pass
	else:
		style.content_margin_left = 8
		style.content_margin_top = 8
		style.content_margin_right = 8
		style.content_margin_bottom = 8
	add_theme_stylebox_override("panel", style)


func _join_tags(tags) -> String:
	if typeof(tags) != TYPE_ARRAY or tags.is_empty():
		return "-"
	var values: Array[String] = []
	for tag in tags:
		values.append(str(tag))
	return "、".join(values)


func _apply_icon_asset(art_asset: Dictionary) -> void:
	icon_texture_rect.visible = false
	icon_texture_rect.texture = null
	var path := str(art_asset.get("path", ""))
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	var image := Image.new()
	if image.load(path) != OK:
		return
	icon_texture_rect.texture = ImageTexture.create_from_image(image)
	icon_texture_rect.visible = true
