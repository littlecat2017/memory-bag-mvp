extends PanelContainer

signal memory_dropped(data: Dictionary, target_kind: String, target_index: int)

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
	preview.add_theme_color_override("font_color", Color(0.96, 0.90, 0.72))
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
	icon_texture_rect.custom_minimum_size = Vector2(34, 34) if compact_mode else Vector2(46, 46)
	effect_label.visible = not compact_mode
	relation_label.visible = not compact_mode
	obligation_label.visible = not compact_mode
	loss_hint_label.visible = not compact_mode
	tags_label.visible = not compact_mode or not zone_kind.is_empty() or memory_id.is_empty()
	title_label.add_theme_font_size_override("font_size", 13 if compact_mode else 18)
	tags_label.add_theme_font_size_override("font_size", 10 if compact_mode else 13)
	if compact_mode:
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_texture_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if zone_kind == "trash":
			title_label.add_theme_color_override("font_color", Color(1.0, 0.56, 0.48))
			tags_label.add_theme_color_override("font_color", Color(0.95, 0.74, 0.64))
		elif zone_kind == "found":
			title_label.add_theme_color_override("font_color", Color(0.76, 0.94, 1.0))
			tags_label.add_theme_color_override("font_color", Color(0.70, 0.84, 0.90))
		else:
			title_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.66))
			tags_label.add_theme_color_override("font_color", Color(0.72, 0.66, 0.52))
	else:
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		tags_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		icon_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_label.add_theme_color_override("font_color", Color.WHITE)
		tags_label.add_theme_color_override("font_color", Color.WHITE)


func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	if compact_mode:
		if zone_kind == "trash":
			style.bg_color = Color(0.13, 0.055, 0.045, 0.94)
			style.border_color = Color(0.68, 0.23, 0.18, 0.95)
		elif zone_kind == "found":
			style.bg_color = Color(0.045, 0.105, 0.13, 0.94)
			style.border_color = Color(0.28, 0.62, 0.72, 0.96)
		elif memory_id.is_empty():
			style.bg_color = Color(0.11, 0.095, 0.070, 0.90)
			style.border_color = Color(0.40, 0.32, 0.19, 0.92)
		else:
			style.bg_color = Color(0.20, 0.155, 0.090, 0.96)
			style.border_color = Color(0.78, 0.58, 0.26, 0.98)
	else:
		style.bg_color = Color(0.10, 0.08, 0.06, 0.86)
		style.border_color = Color(0.48, 0.36, 0.20, 0.92)
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
