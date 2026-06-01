extends RefCounted

signal event_changed(event: Dictionary)
signal memory_replacement_requested(memory_id: String, next_event_id: String)
signal script_finished

var registry
var state
var pending_after_replacement_event_id := ""
var active_stop_event_id := ""


func setup(data_registry, game_state) -> void:
	registry = data_registry
	state = game_state


func start(event_id: String, stop_event_id: String = "") -> void:
	active_stop_event_id = stop_event_id
	_go_to_event(event_id)


func current_event() -> Dictionary:
	if state.current_event_id.is_empty():
		return {}
	return registry.script_events.get(state.current_event_id, {})


func advance() -> void:
	var event: Dictionary = current_event()
	if event.is_empty():
		script_finished.emit()
		return
	if str(event.get("type", "")) == "choice":
		return
	if not active_stop_event_id.is_empty() and state.current_event_id == active_stop_event_id:
		state.current_event_id = ""
		script_finished.emit()
		return
	var next_id: String = _next_event_id(state.current_event_id)
	if next_id.is_empty():
		state.current_event_id = ""
		script_finished.emit()
		return
	if _would_leave_active_segment(next_id):
		state.current_event_id = ""
		script_finished.emit()
		return
	_go_to_event(next_id)


func select_choice(option_index: int) -> void:
	var event: Dictionary = current_event()
	if str(event.get("type", "")) != "choice":
		return
	var visible_options: Array[Dictionary] = get_visible_options(event)
	if option_index < 0 or option_index >= visible_options.size():
		return
	var option: Dictionary = visible_options[option_index]
	var effects: Dictionary = option.get("effects", {})
	state.record_choice(str(event.get("id", "")), str(option.get("label", "")), str(option.get("target", "")))
	if _effects_need_memory_replacement(effects):
		state.apply_non_gain_effects(effects)
		var memory_id: String = str(effects.get("gain", [])[0])
		state.begin_memory_replacement(memory_id)
		pending_after_replacement_event_id = str(option.get("target", ""))
		memory_replacement_requested.emit(memory_id, pending_after_replacement_event_id)
		return
	state.apply_effects(effects)
	_go_to_event(str(option.get("target", "")))


func finish_memory_replacement() -> void:
	var next_id := pending_after_replacement_event_id
	pending_after_replacement_event_id = ""
	if next_id.is_empty():
		advance()
	else:
		_go_to_event(next_id)


func get_visible_options(event: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for option in event.get("options", []):
		if typeof(option) != TYPE_DICTIONARY:
			continue
		if option.has("requires") and not evaluate_condition_list(str(option.requires)):
			continue
		result.append(option)
	return result


func evaluate_condition_list(text: String) -> bool:
	for condition in text.split(",", false):
		if not evaluate_condition(condition.strip_edges()):
			return false
	return true


func evaluate_condition(condition: String) -> bool:
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


func _go_to_event(event_id: String) -> void:
	if event_id.is_empty() or not registry.script_events.has(event_id):
		state.current_event_id = ""
		script_finished.emit()
		return
	state.current_event_id = event_id
	var guard := 0
	while guard < registry.script_event_order.size():
		guard += 1
		var event: Dictionary = registry.script_events.get(state.current_event_id, {})
		if event.is_empty():
			state.current_event_id = ""
			script_finished.emit()
			return
		if _event_condition_passes(event):
			_on_enter_event(event)
			event_changed.emit(event)
			return
		var next_id := _next_event_id(state.current_event_id)
		if next_id.is_empty():
			state.current_event_id = ""
			script_finished.emit()
			return
		state.current_event_id = next_id
	state.current_event_id = ""
	script_finished.emit()


func _event_condition_passes(event: Dictionary) -> bool:
	if not event.has("condition"):
		return true
	return evaluate_condition_list(str(event.condition))


func _on_enter_event(event: Dictionary) -> void:
	var event_id: String = str(event.get("id", ""))
	if state.seen_event_ids.has(event_id):
		return
	state.remember_event(event_id)
	var event_type: String = str(event.get("type", ""))
	if event_type == "memory_offer" and event.has("memory_id"):
		state.offer_memory(str(event.memory_id))
	if event.has("effects") and event_type != "choice":
		var effects: Dictionary = event.effects
		if _effects_need_memory_replacement(effects):
			state.apply_non_gain_effects(effects)
			var memory_id: String = str(effects.get("gain", [])[0])
			state.begin_memory_replacement(memory_id)
			pending_after_replacement_event_id = _next_event_id(event_id)
			memory_replacement_requested.emit(memory_id, pending_after_replacement_event_id)
		else:
			state.apply_effects(effects)


func _effects_need_memory_replacement(effects: Dictionary) -> bool:
	if not bool(effects.get("open_memory_replace", false)):
		return false
	var gains = effects.get("gain", [])
	if typeof(gains) != TYPE_ARRAY or gains.is_empty():
		return false
	var memory_id: String = str(gains[0])
	return not state.can_gain_without_replacement(memory_id)


func _next_event_id(event_id: String) -> String:
	if registry.branch_continue_by_target.has(event_id):
		return str(registry.branch_continue_by_target[event_id])
	var index: int = registry.script_event_order.find(event_id)
	if index == -1 or index + 1 >= registry.script_event_order.size():
		return ""
	return registry.script_event_order[index + 1]


func _would_leave_active_segment(next_event_id: String) -> bool:
	if active_stop_event_id.is_empty():
		return false
	var stop_index: int = registry.script_event_order.find(active_stop_event_id)
	var next_index: int = registry.script_event_order.find(next_event_id)
	if stop_index == -1 or next_index == -1:
		return false
	return next_index > stop_index
