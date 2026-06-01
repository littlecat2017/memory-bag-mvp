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
var level := 1
var exp := 0
var gold := 0
var memory_fragment := 0
var hp := 1
var base_stats: Dictionary = {}
var last_battle_log: Array[String] = []
var last_battle_result: Dictionary = {}
var current_ending_id := ""
var ending_history: Array[String] = []


func configure_from_balance(balance: Dictionary) -> void:
	var initial_player: Dictionary = balance.get("initial_player", {})
	display_name = str(initial_player.get("display_name", display_name))
	fallback_display_name = str(initial_player.get("fallback_display_name", fallback_display_name))
	level = int(initial_player.get("level", level))
	exp = int(initial_player.get("exp", exp))
	gold = int(initial_player.get("gold", gold))
	base_stats = initial_player.get("base_stats", {}).duplicate(true)
	if base_stats.is_empty():
		base_stats = {
			"max_hp": 120,
			"atk": 12,
			"def": 2,
			"speed": 1.0,
			"crit_rate": 0.05,
			"crit_damage": 1.75,
			"regen_per_5s": 0,
			"camp_heal_rate": 0.35,
			"memory_resist": 0,
			"boss_damage_bonus": 0,
			"progress_speed": 1.0,
			"healing_received": 1.0,
			"normal_attack_damage": 0,
		}
	hp = int(initial_player.get("hp", int(base_stats.get("max_hp", hp))))
	hp = clampi(hp, 1, int(round(float(base_stats.get("max_hp", hp)))))
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


func derived_stats(registry) -> Dictionary:
	var stats := base_stats.duplicate(true)
	_apply_level_stats(stats, registry.balance.get("level_curve", {}))
	var percent_add: Dictionary = {}
	for memory_id in owned_memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		for modifier in memory.get("stat_modifiers", []):
			if typeof(modifier) != TYPE_DICTIONARY:
				continue
			var stat := str(modifier.get("stat", ""))
			var op := str(modifier.get("op", ""))
			var value := float(modifier.get("value", 0.0))
			if stat.is_empty():
				continue
			if op == "add":
				stats[stat] = float(stats.get(stat, 0.0)) + value
			elif op == "percent_add":
				percent_add[stat] = float(percent_add.get(stat, 0.0)) + value
	var combat: Dictionary = registry.balance.get("combat", {})
	for stat in percent_add.keys():
		var percent := float(percent_add[stat])
		if stat == "atk":
			percent = min(percent, float(combat.get("atk_percent_bonus_cap", 0.6)))
		elif stat == "boss_damage_bonus":
			percent = min(percent, float(combat.get("boss_damage_bonus_cap", 0.5)))
		stats[stat] = float(stats.get(stat, 0.0)) * (1.0 + percent)
	stats["crit_rate"] = clampf(float(stats.get("crit_rate", 0.0)), 0.0, float(combat.get("crit_rate_cap", 0.45)))
	stats["speed"] = max(0.1, float(stats.get("speed", 1.0)))
	stats["healing_received"] = max(0.0, float(stats.get("healing_received", 1.0)))
	return stats


func heal_flat(amount: int, stats: Dictionary) -> int:
	var final_amount := int(round(float(amount) * float(stats.get("healing_received", 1.0))))
	if final_amount <= 0:
		return 0
	var max_hp := int(round(float(stats.get("max_hp", base_stats.get("max_hp", hp)))))
	var before := hp
	hp = clampi(hp + final_amount, 0, max_hp)
	return hp - before


func take_damage(amount: int) -> int:
	var damage: int = max(0, amount)
	hp = max(0, hp - damage)
	return damage


func apply_reward_aliases(reward_ids: Array, aliases: Dictionary, balance: Dictionary) -> Dictionary:
	var applied := {
		"exp": 0,
		"gold": 0,
		"memory_fragment": 0,
		"mvp_ending": false,
		"levels_gained": 0,
	}
	for reward_id in reward_ids:
		var reward: Dictionary = aliases.get(str(reward_id), {})
		if reward.is_empty():
			continue
		applied["exp"] = int(applied["exp"]) + int(reward.get("exp", 0))
		applied["gold"] = int(applied["gold"]) + int(reward.get("gold", 0))
		applied["memory_fragment"] = int(applied["memory_fragment"]) + int(reward.get("memory_fragment", 0))
		if bool(reward.get("mvp_ending", false)):
			applied["mvp_ending"] = true
	gold += int(applied["gold"])
	memory_fragment += int(applied["memory_fragment"])
	if bool(applied["mvp_ending"]):
		flags["chapter_unlock_mountain"] = true
	var levels_before := level
	_add_exp(int(applied["exp"]), balance)
	applied["levels_gained"] = level - levels_before
	return applied


func remember_event(event_id: String) -> void:
	if not seen_event_ids.has(event_id):
		seen_event_ids.append(event_id)


func remember_ending(ending_id: String) -> void:
	current_ending_id = ending_id
	if not ending_history.has(ending_id):
		ending_history.append(ending_id)


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


func _apply_level_stats(stats: Dictionary, level_curve: Dictionary) -> void:
	var per_level: Dictionary = level_curve.get("per_level", {})
	var even_level_bonus: Dictionary = level_curve.get("even_level_bonus", {})
	var every_3_levels_bonus: Dictionary = level_curve.get("every_3_levels_bonus", {})
	for current_level in range(2, level + 1):
		_apply_stat_adds(stats, per_level)
		if current_level % 2 == 0:
			_apply_stat_adds(stats, even_level_bonus)
		if current_level % 3 == 0:
			_apply_stat_adds(stats, every_3_levels_bonus)


func _apply_stat_adds(stats: Dictionary, adds: Dictionary) -> void:
	for stat in adds.keys():
		stats[stat] = float(stats.get(stat, 0.0)) + float(adds[stat])


func _add_exp(amount: int, balance: Dictionary) -> void:
	if amount <= 0:
		return
	exp += amount
	var level_curve: Dictionary = balance.get("level_curve", {})
	var max_level := int(level_curve.get("max_level", 12))
	var guard := 0
	while level < max_level and guard < 100:
		guard += 1
		var required := _next_exp_required()
		if exp < required:
			break
		exp -= required
		level += 1
		_heal_level_up_bonus(level_curve)


func _next_exp_required() -> int:
	return 50 + level * 35


func _heal_level_up_bonus(level_curve: Dictionary) -> void:
	var per_level: Dictionary = level_curve.get("per_level", {})
	var hp_gain := int(per_level.get("max_hp", 0))
	if hp_gain > 0:
		hp += hp_gain
