extends PanelContainer

var title_label: Label
var tags_label: Label
var effect_label: Label
var relation_label: Label
var obligation_label: Label
var loss_hint_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(280, 210)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build()


func set_empty(slot_index: int) -> void:
	title_label.text = "空记忆格 %d" % slot_index
	tags_label.text = "标签：-"
	effect_label.text = "效果：-"
	relation_label.text = "关系：-"
	obligation_label.text = "承诺：-"
	loss_hint_label.text = "丢弃提示：-"


func set_memory(memory: Dictionary) -> void:
	title_label.text = str(memory.get("name", "未知记忆"))
	tags_label.text = "标签：%s" % _join_tags(memory.get("tags", []))
	effect_label.text = "效果：%s" % memory.get("effect_text", "")
	relation_label.text = "关系：%s / %s" % [
		memory.get("relation_target", ""),
		memory.get("relation_type", ""),
	]
	obligation_label.text = "承诺：%s" % memory.get("obligation", "")
	loss_hint_label.text = "丢弃提示：%s" % memory.get("ui_loss_hint", "")


func has_required_memory_text() -> bool:
	return not title_label.text.is_empty() \
		and relation_label.text.find("关系：") == 0 \
		and obligation_label.text.find("承诺：") == 0 \
		and loss_hint_label.text.find("丢弃提示：") == 0


func _build() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	margin.add_child(box)

	title_label = _new_label(18)
	title_label.text = "空记忆格"
	box.add_child(title_label)

	tags_label = _new_label(13)
	box.add_child(tags_label)

	effect_label = _new_label(13)
	box.add_child(effect_label)

	relation_label = _new_label(13)
	box.add_child(relation_label)

	obligation_label = _new_label(13)
	box.add_child(obligation_label)

	loss_hint_label = _new_label(12)
	box.add_child(loss_hint_label)


func _new_label(font_size: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _join_tags(tags) -> String:
	if typeof(tags) != TYPE_ARRAY or tags.is_empty():
		return "-"
	var values: Array[String] = []
	for tag in tags:
		values.append(str(tag))
	return "、".join(values)
