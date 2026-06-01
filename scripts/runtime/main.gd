extends Control

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")

var registry = DataRegistryScript.new()


func _ready() -> void:
	var ok := registry.load_all()
	print(registry.summary())
	for error in registry.validation_errors:
		push_error(error)
	_add_label(ok)


func _add_label(ok: bool) -> void:
	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = "记忆背包 MVP\n%s\n\n本轮目标：数据加载与校验" % [
		"校验通过" if ok else "校验失败：%d 个错误" % registry.validation_errors.size()
	]
	add_child(label)
