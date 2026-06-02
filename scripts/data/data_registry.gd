class_name DataRegistry
extends RefCounted

const DATA_PATHS := {
	"memories": "res://data/memories.json",
	"enemies": "res://data/enemies.json",
	"chapter_flow": "res://data/chapter_flow.json",
	"balance": "res://data/balance.json",
	"mvp_endings": "res://data/mvp_endings.json",
	"art_assets": "res://data/art_assets.json",
	"script_events": "res://data/script_events_mvp.jsonl",
}

var memories: Dictionary = {}
var enemies: Dictionary = {}
var script_events: Dictionary = {}
var script_event_order: Array[String] = []
var branch_continue_by_target: Dictionary = {}
var chapter_flow: Dictionary = {}
var balance: Dictionary = {}
var mvp_endings: Dictionary = {}
var art_assets: Dictionary = {}
var art_assets_by_type: Dictionary = {}
var art_asset_aliases: Dictionary = {}
var validation_errors: Array[String] = []


func load_all() -> bool:
	validation_errors.clear()
	memories = _load_items_file(DATA_PATHS.memories, "memory")
	enemies = _load_items_file(DATA_PATHS.enemies, "enemy")
	chapter_flow = _load_json_file(DATA_PATHS.chapter_flow)
	balance = _load_json_file(DATA_PATHS.balance)
	mvp_endings = _load_json_file(DATA_PATHS.mvp_endings)
	art_assets = _load_items_file(DATA_PATHS.art_assets, "art_asset")
	script_events = _load_jsonl_events(DATA_PATHS.script_events)
	_build_branch_lookup()
	_build_art_asset_type_lookup()
	validate()
	return validation_errors.is_empty()


func summary() -> String:
	return "DataRegistry: memories=%d enemies=%d script_events=%d art_assets=%d validation_errors=%d" % [
		memories.size(),
		enemies.size(),
		script_events.size(),
		art_assets.size(),
		validation_errors.size(),
	]


func validate() -> void:
	_validate_memory_relation_fields()
	_validate_script_references()
	_validate_chapter_flow_references()
	_validate_ending_conditions()
	_validate_art_assets()


func get_art_asset(asset_id: String, expected_type: String = "") -> Dictionary:
	if asset_id.is_empty() or asset_id == "none":
		return {}
	var asset: Dictionary = art_assets.get(asset_id, art_asset_aliases.get(asset_id, {}))
	if asset.is_empty():
		return {}
	if not expected_type.is_empty() and str(asset.get("type", "")) != expected_type:
		return {}
	return asset


func get_art_asset_for_memory(memory_id: String, expected_type: String = "memory_icon") -> Dictionary:
	for asset in art_assets_by_type.get(expected_type, {}).values():
		if typeof(asset) == TYPE_DICTIONARY and str(asset.get("memory_id", "")) == memory_id:
			return asset
	return {}


func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		validation_errors.append("Missing JSON file: %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		validation_errors.append("Invalid JSON object: %s" % path)
		return {}
	return parsed


func _load_items_file(path: String, label: String) -> Dictionary:
	var root := _load_json_file(path)
	var result: Dictionary = {}
	var items = root.get("items", [])
	if typeof(items) != TYPE_ARRAY:
		validation_errors.append("%s items must be an array: %s" % [label, path])
		return result
	for item in items:
		if typeof(item) != TYPE_DICTIONARY:
			validation_errors.append("%s item is not an object in %s" % [label, path])
			continue
		var item_id := str(item.get("id", ""))
		if item_id.is_empty():
			validation_errors.append("%s item missing id in %s" % [label, path])
			continue
		if result.has(item_id):
			validation_errors.append("Duplicate %s id: %s" % [label, item_id])
			continue
		result[item_id] = item
	return result


func _load_jsonl_events(path: String) -> Dictionary:
	var result: Dictionary = {}
	script_event_order.clear()
	if not FileAccess.file_exists(path):
		validation_errors.append("Missing JSONL file: %s" % path)
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		validation_errors.append("Could not open JSONL file: %s" % path)
		return result
	var line_no := 0
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		line_no += 1
		if line.is_empty():
			continue
		var parsed = JSON.parse_string(line)
		if typeof(parsed) != TYPE_DICTIONARY:
			validation_errors.append("Invalid JSONL object at %s:%d" % [path, line_no])
			continue
		var event_id := str(parsed.get("id", ""))
		if event_id.is_empty():
			validation_errors.append("Script event missing id at %s:%d" % [path, line_no])
			continue
		if result.has(event_id):
			validation_errors.append("Duplicate script event id: %s" % event_id)
			continue
		result[event_id] = parsed
		script_event_order.append(event_id)
	return result


func _build_branch_lookup() -> void:
	branch_continue_by_target.clear()
	for merge in chapter_flow.get("branch_merges", []):
		if typeof(merge) != TYPE_DICTIONARY:
			continue
		var continue_event_id := str(merge.get("continue_event_id", ""))
		for target_id in merge.get("branch_target_ids", []):
			branch_continue_by_target[str(target_id)] = continue_event_id


func _build_art_asset_type_lookup() -> void:
	art_assets_by_type.clear()
	art_asset_aliases.clear()
	for asset_id in art_assets:
		var asset: Dictionary = art_assets[asset_id]
		var asset_type := str(asset.get("type", ""))
		if asset_type.is_empty():
			continue
		if not art_assets_by_type.has(asset_type):
			art_assets_by_type[asset_type] = {}
		art_assets_by_type[asset_type][asset_id] = asset
		for alias_id in asset.get("aliases", []):
			art_asset_aliases[str(alias_id)] = asset


func _validate_memory_relation_fields() -> void:
	var required := [
		"relation_target",
		"relation_type",
		"obligation",
		"owned_world_response",
		"discard_world_response",
		"ui_loss_hint",
	]
	for memory_id in memories:
		var memory: Dictionary = memories[memory_id]
		for field in required:
			if not memory.has(field) or str(memory[field]).strip_edges().is_empty():
				validation_errors.append("Memory %s missing required relation field: %s" % [memory_id, field])


func _validate_script_references() -> void:
	for event_id in script_events:
		var event: Dictionary = script_events[event_id]
		var event_type := str(event.get("type", ""))
		if event.has("memory_id"):
			_validate_memory_id(str(event.memory_id), "event %s memory_id" % event_id)
		if event_type == "battle":
			for enemy_id in str(event.get("enemy_id", "")).split(",", false):
				_validate_enemy_id(enemy_id.strip_edges(), "battle event %s" % event_id)
		if event_type == "choice":
			_validate_choice(event_id, event)
		if event.has("effects"):
			_validate_effects("event %s effects" % event_id, event.effects)


func _validate_choice(event_id: String, event: Dictionary) -> void:
	var options = event.get("options", [])
	if typeof(options) != TYPE_ARRAY:
		validation_errors.append("Choice %s options must be an array" % event_id)
		return
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			validation_errors.append("Choice %s has non-object option" % event_id)
			continue
		var target := str(option.get("target", ""))
		if target.is_empty():
			validation_errors.append("Choice %s option missing target" % event_id)
		elif target != "EVAL_ENDING" and not script_events.has(target):
			validation_errors.append("Choice %s option target not found: %s" % [event_id, target])
		if option.has("requires"):
			_validate_condition_list("choice %s requires" % event_id, str(option.requires))
		if option.has("effects"):
			_validate_effects("choice %s option effects" % event_id, option.effects)


func _validate_effects(context: String, effects) -> void:
	if typeof(effects) != TYPE_DICTIONARY:
		validation_errors.append("%s must be an object" % context)
		return
	for key in ["gain", "discard", "consume"]:
		if not effects.has(key):
			continue
		var values = effects[key]
		if typeof(values) != TYPE_ARRAY:
			validation_errors.append("%s.%s must be an array" % [context, key])
			continue
		for memory_id in values:
			_validate_memory_id(str(memory_id), "%s.%s" % [context, key])


func _validate_chapter_flow_references() -> void:
	for chapter in chapter_flow.get("chapters", []):
		if typeof(chapter) != TYPE_DICTIONARY:
			validation_errors.append("chapter_flow chapter is not an object")
			continue
		for key in ["start_event_id", "end_event_id"]:
			if chapter.has(key):
				_validate_script_event_id(str(chapter[key]), "chapter %s %s" % [chapter.get("chapter_id", "?"), key])
		for node in chapter.get("nodes", []):
			if typeof(node) != TYPE_DICTIONARY:
				validation_errors.append("chapter_flow node is not an object")
				continue
			var node_id := str(node.get("node_id", "?"))
			for key in ["event_id", "start_event_id", "end_event_id", "trigger_after_event_id"]:
				if node.has(key):
					_validate_script_event_id(str(node[key]), "node %s %s" % [node_id, key])
	for merge in chapter_flow.get("branch_merges", []):
		if typeof(merge) != TYPE_DICTIONARY:
			validation_errors.append("branch merge is not an object")
			continue
		_validate_script_event_id(str(merge.get("choice_id", "")), "branch merge choice_id")
		_validate_script_event_id(str(merge.get("continue_event_id", "")), "branch merge continue_event_id")
		for target_id in merge.get("branch_target_ids", []):
			_validate_script_event_id(str(target_id), "branch merge branch_target_id")


func _validate_ending_conditions() -> void:
	for rule in mvp_endings.get("rules", []):
		if typeof(rule) != TYPE_DICTIONARY:
			validation_errors.append("ending rule is not an object")
			continue
		for condition in rule.get("conditions", []):
			_validate_condition("ending %s condition" % rule.get("id", "?"), str(condition))


func _validate_art_assets() -> void:
	var allowed_types := ["background", "portrait", "enemy", "chibi_sheet", "chibi_unit", "memory_icon", "effect_sheet", "ui"]
	for asset_id in art_assets:
		var asset: Dictionary = art_assets[asset_id]
		var asset_type := str(asset.get("type", ""))
		var path := str(asset.get("path", ""))
		if not allowed_types.has(asset_type):
			validation_errors.append("Art asset %s has unknown type: %s" % [asset_id, asset_type])
		if path.is_empty() or not FileAccess.file_exists(path):
			validation_errors.append("Art asset %s missing file: %s" % [asset_id, path])
		var expected_size = asset.get("expected_size", [])
		if typeof(expected_size) != TYPE_ARRAY or expected_size.size() != 2:
			validation_errors.append("Art asset %s expected_size must be [width, height]" % asset_id)
		var aliases = asset.get("aliases", [])
		if typeof(aliases) != TYPE_ARRAY:
			validation_errors.append("Art asset %s aliases must be an array" % asset_id)
		if asset_type == "memory_icon":
			_validate_memory_id(str(asset.get("memory_id", "")), "art asset %s memory_id" % asset_id)


func _validate_condition_list(context: String, text: String) -> void:
	for condition in text.split(",", false):
		_validate_condition(context, condition.strip_edges())


func _validate_condition(context: String, condition: String) -> void:
	if condition.begins_with("has_memory:"):
		_validate_memory_id(condition.trim_prefix("has_memory:"), context)
	elif condition.begins_with("not_has_memory:"):
		_validate_memory_id(condition.trim_prefix("not_has_memory:"), context)
	elif condition.begins_with("discarded:"):
		_validate_memory_id(condition.trim_prefix("discarded:"), context)
	elif condition.begins_with("not_discarded:"):
		_validate_memory_id(condition.trim_prefix("not_discarded:"), context)


func _validate_memory_id(memory_id: String, context: String) -> void:
	if memory_id.is_empty() or not memories.has(memory_id):
		validation_errors.append("%s references unknown memory id: %s" % [context, memory_id])


func _validate_enemy_id(enemy_id: String, context: String) -> void:
	if enemy_id.is_empty() or not enemies.has(enemy_id):
		validation_errors.append("%s references unknown enemy id: %s" % [context, enemy_id])


func _validate_script_event_id(event_id: String, context: String) -> void:
	if event_id.is_empty() or not script_events.has(event_id):
		validation_errors.append("%s references unknown script event id: %s" % [context, event_id])
