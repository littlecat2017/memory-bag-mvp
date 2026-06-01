extends RefCounted

var display_name := "艾尔"
var fallback_display_name := "勇者"
var current_event_id := ""
var flags: Dictionary = {}
var route := ""
var owned_memory_ids: Array[String] = []
var discarded_memory_ids: Array[String] = []
var consumed_memory_ids: Array[String] = []
var offered_memory_ids: Array[String] = []
var seen_event_ids: Array[String] = []
var choice_history: Array[Dictionary] = []
var world_feedback_history: Array[String] = []
var pending_memory_id := ""
var capacity_base := 4
var capacity_bonus_temp := 0
var capacity_penalty := 0


func configure_from_balance(balance: Dictionary) -> void:
	var initial_player: Dictionary = balance.get("initial_player", {})
	display_name = str(initial_player.get("display_name", display_name))
	fallback_display_name = str(initial_player.get("fallback_display_name", fallback_display_name))
	var bag: Dictionary = balance.get("bag", {})
	capacity_base = int(bag.get("capacity_base", capacity_base))
	capacity_bonus_temp = int(bag.get("capacity_bonus_temp", capacity_bonus_temp))
	capacity_penalty = int(bag.get("capacity_penalty", capacity_penalty))


func capacity() -> int:
	return max(0, capacity_base + capacity_bonus_temp - capacity_penalty)


func has_memory(memory_id: String) -> bool:
	return owned_memory_ids.has(memory_id)


func has_discarded(memory_id: String) -> bool:
	return discarded_memory_ids.has(memory_id)


func has_flag(flag_id: String) -> bool:
	return flags.has(flag_id) and bool(flags[flag_id])


func offer_memory(memory_id: String) -> void:
	if not offered_memory_ids.has(memory_id):
		offered_memory_ids.append(memory_id)


func can_gain_without_replacement(memory_id: String) -> bool:
	return owned_memory_ids.has(memory_id) or owned_memory_ids.size() < capacity()


func begin_memory_replacement(memory_id: String) -> void:
	offer_memory(memory_id)
	pending_memory_id = memory_id


func has_pending_memory() -> bool:
	return not pending_memory_id.is_empty()


func gain_memory(memory_id: String) -> void:
	if memory_id.is_empty():
		return
	_remove_string(discarded_memory_ids, memory_id)
	_remove_string(consumed_memory_ids, memory_id)
	if not owned_memory_ids.has(memory_id):
		owned_memory_ids.append(memory_id)


func discard_memory(memory_id: String) -> void:
	_remove_string(owned_memory_ids, memory_id)
	_remove_string(consumed_memory_ids, memory_id)
	if not discarded_memory_ids.has(memory_id):
		discarded_memory_ids.append(memory_id)
	if memory_id == "mem_my_name":
		display_name = fallback_display_name
		flags["ui_name_erased"] = true


func accept_pending_by_discard(memory_id: String, registry) -> void:
	if pending_memory_id.is_empty():
		return
	discard_memory(memory_id)
	gain_memory(pending_memory_id)
	_append_discard_feedback(memory_id, registry)
	pending_memory_id = ""


func decline_pending_memory() -> void:
	pending_memory_id = ""


func consume_memory(memory_id: String) -> void:
	_remove_string(owned_memory_ids, memory_id)
	_remove_string(discarded_memory_ids, memory_id)
	if not consumed_memory_ids.has(memory_id):
		consumed_memory_ids.append(memory_id)


func apply_effects(effects: Dictionary) -> void:
	for memory_id in effects.get("discard", []):
		discard_memory(str(memory_id))
	for memory_id in effects.get("consume", []):
		consume_memory(str(memory_id))
	for memory_id in effects.get("gain", []):
		gain_memory(str(memory_id))
	var set_flags = effects.get("set_flags", [])
	if typeof(set_flags) == TYPE_ARRAY:
		for flag_id in set_flags:
			flags[str(flag_id)] = true
	elif typeof(set_flags) == TYPE_STRING:
		flags[str(set_flags)] = true
	if effects.has("set_route"):
		route = str(effects.set_route)


func apply_non_gain_effects(effects: Dictionary) -> void:
	var copy := effects.duplicate(true)
	copy.erase("gain")
	copy.erase("open_memory_replace")
	apply_effects(copy)


func remember_event(event_id: String) -> void:
	if not seen_event_ids.has(event_id):
		seen_event_ids.append(event_id)


func record_choice(event_id: String, label: String, target: String) -> void:
	choice_history.append({
		"event_id": event_id,
		"label": label,
		"target": target,
	})


func bag_summary(registry) -> String:
	if owned_memory_ids.is_empty():
		return "背包为空"
	var names: Array[String] = []
	for memory_id in owned_memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		names.append("%s（%s）" % [
			memory.get("name", memory_id),
			memory.get("relation_target", "?"),
		])
	return " / ".join(names)


func _append_discard_feedback(memory_id: String, registry) -> void:
	var memory: Dictionary = registry.memories.get(memory_id, {})
	var memory_name := str(memory.get("name", memory_id))
	var discard_text := str(memory.get("discard_text", ""))
	var world_text := str(memory.get("discard_world_response", ""))
	if not discard_text.is_empty():
		world_feedback_history.append("%s：%s" % [memory_name, discard_text])
	if not world_text.is_empty():
		world_feedback_history.append("%s：%s" % [memory_name, world_text])


func _remove_string(values: Array[String], value: String) -> void:
	while values.has(value):
		values.erase(value)
