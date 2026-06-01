extends RefCounted

var registry
var state


func setup(data_registry, game_state) -> void:
	registry = data_registry
	state = game_state


func evaluate_mvp_ending() -> Dictionary:
	var rules: Array = registry.mvp_endings.get("rules", [])
	var sorted_rules := rules.duplicate(true)
	sorted_rules.sort_custom(_sort_by_priority)
	for rule in sorted_rules:
		if typeof(rule) != TYPE_DICTIONARY:
			continue
		if _conditions_pass(rule.get("conditions", [])):
			var ending_id := str(rule.get("id", ""))
			state.remember_ending(ending_id)
			return {
				"id": ending_id,
				"lines": _copy_lines(rule.get("lines", [])),
			}
	return {
		"id": "",
		"lines": [],
	}


func _conditions_pass(conditions: Array) -> bool:
	for condition in conditions:
		if not _condition_passes(str(condition)):
			return false
	return true


func _condition_passes(condition: String) -> bool:
	if condition.is_empty():
		return true
	if condition.begins_with("has_memory:"):
		return state.has_memory(condition.trim_prefix("has_memory:"))
	if condition.begins_with("not_has_memory:"):
		return not state.has_memory(condition.trim_prefix("not_has_memory:"))
	if condition.begins_with("discarded:"):
		return state.has_discarded(condition.trim_prefix("discarded:"))
	if condition.begins_with("not_discarded:"):
		return not state.has_discarded(condition.trim_prefix("not_discarded:"))
	if condition.begins_with("has_flag:"):
		return state.has_flag(condition.trim_prefix("has_flag:"))
	if condition.begins_with("not_has_flag:"):
		return not state.has_flag(condition.trim_prefix("not_has_flag:"))
	if condition.begins_with("route:"):
		return state.route == condition.trim_prefix("route:")
	return false


func _copy_lines(lines: Array) -> Array[Dictionary]:
	var copied: Array[Dictionary] = []
	for line in lines:
		if typeof(line) == TYPE_DICTIONARY:
			copied.append(line.duplicate(true))
	return copied


func _sort_by_priority(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("priority", 9999)) < int(b.get("priority", 9999))
