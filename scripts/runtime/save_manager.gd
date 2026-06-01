extends RefCounted

const SCHEMA_VERSION := 1
const DEFAULT_SAVE_PATH := "user://save_slot_1.json"

var last_error := ""


func save_to_file(path: String, state, run_controller, script_player, ui_context: Dictionary = {}) -> bool:
	last_error = ""
	var root := {
		"schema_version": SCHEMA_VERSION,
		"saved_at_unix": Time.get_unix_time_from_system(),
		"state": state.to_save_data(),
		"run": run_controller.to_save_data(),
		"script_player": script_player.to_save_data(),
		"ui": ui_context.duplicate(true),
	}
	var json := JSON.stringify(root, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		last_error = "无法写入存档：%s" % path
		return false
	file.store_string(json)
	return true


func load_from_file(path: String, state, run_controller, script_player) -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(path):
		last_error = "存档不存在：%s" % path
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "存档格式错误：%s" % path
		return {}
	if int(parsed.get("schema_version", 0)) != SCHEMA_VERSION:
		last_error = "存档版本不匹配：%s" % path
		return {}
	var state_data = parsed.get("state", {})
	var run_data = parsed.get("run", {})
	var script_data = parsed.get("script_player", {})
	if typeof(state_data) != TYPE_DICTIONARY or typeof(run_data) != TYPE_DICTIONARY or typeof(script_data) != TYPE_DICTIONARY:
		last_error = "存档缺少必要字段：%s" % path
		return {}
	state.load_save_data(state_data)
	run_controller.load_save_data(run_data)
	script_player.load_save_data(script_data)
	var ui = parsed.get("ui", {})
	return ui.duplicate(true) if typeof(ui) == TYPE_DICTIONARY else {}
