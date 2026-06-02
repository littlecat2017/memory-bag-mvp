extends RefCounted

var registry
var state
var rng := RandomNumberGenerator.new()
var logs: Array[String] = []
var timeline: Array[Dictionary] = []


func setup(data_registry, game_state) -> void:
	registry = data_registry
	state = game_state


func run_event(event: Dictionary) -> Dictionary:
	var event_id := str(event.get("id", ""))
	var enemy_ids := _parse_enemy_ids(str(event.get("enemy_id", "")))
	logs.clear()
	timeline.clear()
	rng.seed = hash("%s:%s" % [event_id, ",".join(enemy_ids)])
	if not event_id.is_empty():
		state.remember_event(event_id)
	_log(str(event.get("text", "自动战斗开始。")))
	var victory := true
	for enemy_id in enemy_ids:
		var enemy_result := run_enemy(enemy_id)
		if not bool(enemy_result.get("victory", false)):
			victory = false
			break
	if victory:
		_apply_post_battle_triggers()
	var rewards := {}
	if victory:
		rewards = state.apply_reward_aliases(event.get("reward", []), registry.balance.get("reward_aliases", {}), registry.balance)
		_log(_reward_text(rewards))
	else:
		_apply_defeat_recovery()
	var result := {
		"event_id": event_id,
		"victory": victory,
		"enemy_ids": enemy_ids,
		"player_hp": state.hp,
		"rewards": rewards,
		"logs": logs.duplicate(),
		"timeline": timeline.duplicate(true),
	}
	state.last_battle_log = logs.duplicate()
	state.last_battle_result = result.duplicate(true)
	return result


func run_enemy(enemy_id: String) -> Dictionary:
	var enemy_base: Dictionary = registry.enemies.get(enemy_id, {})
	if enemy_base.is_empty():
		_log("找不到敌人：%s" % enemy_id)
		return {"victory": false, "enemy_id": enemy_id}
	var enemy: Dictionary = enemy_base.duplicate(true)
	enemy["current_hp"] = int(enemy.get("max_hp", 1))
	enemy["current_def"] = int(enemy.get("def", 0))
	enemy["next_attack_multiplier"] = 1.0
	enemy["triggered_mechanics"] = {}
	_apply_enemy_battle_start_mechanics(enemy)
	_log("遭遇：%s（HP %d）" % [_enemy_name(enemy), int(enemy.current_hp)])
	_stage({
		"type": "enemy_appear",
		"enemy_id": enemy_id,
		"enemy_name": _enemy_name(enemy),
		"enemy_hp": int(enemy.current_hp),
		"enemy_max_hp": int(enemy.get("max_hp", enemy.current_hp)),
		"enemy_tags": _string_array(enemy.get("tags", [])),
	})

	var stats: Dictionary = state.derived_stats(registry)
	var combat: Dictionary = registry.balance.get("combat", {})
	var tick := float(combat.get("logic_tick_seconds", 0.2))
	var max_seconds := 180.0
	var elapsed := 0.0
	var player_attack_timer := 0.0
	var enemy_attack_timer := 0.0
	var player_attack_interval: float = max(0.2, 2.0 / float(stats.get("speed", 1.0)))
	var enemy_attack_interval: float = max(0.2, float(enemy.get("attack_interval", 2.0)))
	var memory_interval_timers := _build_memory_interval_timers()
	var enemy_interval_timers := _build_enemy_interval_timers(enemy)

	while int(enemy.current_hp) > 0 and state.hp > 0 and elapsed < max_seconds:
		elapsed += tick
		player_attack_timer += tick
		enemy_attack_timer += tick
		_tick_memory_intervals(memory_interval_timers, tick, stats)
		_tick_enemy_intervals(enemy, enemy_interval_timers, tick)
		_check_enemy_hp_mechanics(enemy)

		if player_attack_timer + 0.0001 >= player_attack_interval:
			player_attack_timer -= player_attack_interval
			var attack: Dictionary = _player_attack_damage(enemy, stats, false)
			enemy.current_hp = max(0, int(enemy.current_hp) - int(attack.damage))
			_log("勇者攻击 %s，造成 %d 点伤害%s。" % [
				_enemy_name(enemy),
				int(attack.damage),
				"（暴击）" if bool(attack.crit) else "",
			])
			_stage({
				"type": "player_attack",
				"enemy_id": enemy_id,
				"enemy_name": _enemy_name(enemy),
				"damage": int(attack.damage),
				"crit": bool(attack.crit),
				"enemy_hp": int(enemy.current_hp),
				"enemy_max_hp": int(enemy.get("max_hp", 1)),
				"enemy_tags": _string_array(enemy.get("tags", [])),
			})
			_check_enemy_hp_mechanics(enemy)
			if int(enemy.current_hp) <= 0:
				break

		if enemy_attack_timer + 0.0001 >= enemy_attack_interval:
			enemy_attack_timer -= enemy_attack_interval
			var damage := _enemy_attack_damage(enemy, stats)
			state.take_damage(damage)
			_log("%s 攻击勇者，造成 %d 点伤害。" % [_enemy_name(enemy), damage])
			_stage({
				"type": "enemy_attack",
				"enemy_id": enemy_id,
				"enemy_name": _enemy_name(enemy),
				"damage": damage,
				"player_hp": state.hp,
				"enemy_tags": _string_array(enemy.get("tags", [])),
			})

	var victory: bool = int(enemy.current_hp) <= 0 and state.hp > 0
	if victory:
		_log("%s 被击败。" % _enemy_name(enemy))
		_stage({
			"type": "enemy_defeated",
			"enemy_id": enemy_id,
			"enemy_name": _enemy_name(enemy),
			"enemy_tags": _string_array(enemy.get("tags", [])),
		})
	else:
		_log("勇者在 %s 面前濒死。" % _enemy_name(enemy))
		_stage({
			"type": "player_near_death",
			"enemy_id": enemy_id,
			"enemy_name": _enemy_name(enemy),
			"player_hp": state.hp,
			"enemy_tags": _string_array(enemy.get("tags", [])),
		})
	return {
		"enemy_id": enemy_id,
		"victory": victory,
		"elapsed": elapsed,
		"player_hp": state.hp,
		"enemy_hp": int(enemy.current_hp),
	}


func preview_player_attack_damage(enemy_id: String) -> int:
	var enemy_base: Dictionary = registry.enemies.get(enemy_id, {})
	var enemy: Dictionary = enemy_base.duplicate(true)
	enemy["current_def"] = int(enemy.get("def", 0))
	return int(_player_attack_damage(enemy, state.derived_stats(registry), true).damage)


func preview_enemy_attack_damage(enemy_id: String) -> int:
	var enemy_base: Dictionary = registry.enemies.get(enemy_id, {})
	var enemy: Dictionary = enemy_base.duplicate(true)
	enemy["next_attack_multiplier"] = 1.0
	return _enemy_attack_damage(enemy, state.derived_stats(registry))


func _player_attack_damage(enemy: Dictionary, stats: Dictionary, fixed_roll: bool) -> Dictionary:
	var combat: Dictionary = registry.balance.get("combat", {})
	var minimum_damage := int(combat.get("minimum_damage", 1))
	var base_damage: int = max(minimum_damage, int(round(float(stats.get("atk", 0.0)))) - int(enemy.get("current_def", enemy.get("def", 0))))
	base_damage += int(round(float(stats.get("normal_attack_damage", 0.0))))
	var random_factor := 1.0
	if not fixed_roll:
		random_factor = rng.randf_range(float(combat.get("damage_random_min", 0.9)), float(combat.get("damage_random_max", 1.1)))
	var multiplier: float = _conditional_multiplier("damage_dealt", "target_has_tag", enemy.get("tags", []))
	if _has_tag(enemy, "boss"):
		multiplier *= 1.0 + float(stats.get("boss_damage_bonus", 0.0))
	var damage: int = max(minimum_damage, int(round(float(base_damage) * random_factor * multiplier)))
	var crit := false
	if not fixed_roll and rng.randf() < float(stats.get("crit_rate", 0.0)):
		crit = true
		damage = max(minimum_damage, int(round(float(damage) * float(stats.get("crit_damage", 1.75)))))
	return {
		"damage": damage,
		"crit": crit,
	}


func _enemy_attack_damage(enemy: Dictionary, stats: Dictionary) -> int:
	var combat: Dictionary = registry.balance.get("combat", {})
	var minimum_damage := int(combat.get("minimum_damage", 1))
	var base_damage: int = max(minimum_damage, int(enemy.get("atk", 0)) - int(round(float(stats.get("def", 0.0)))))
	var multiplier: float = _conditional_multiplier("damage_taken", "source_has_tag", enemy.get("tags", []))
	multiplier *= float(enemy.get("next_attack_multiplier", 1.0))
	enemy["next_attack_multiplier"] = 1.0
	return max(minimum_damage, int(round(float(base_damage) * multiplier)))


func _conditional_multiplier(stat: String, prefix: String, tags) -> float:
	var percent_add := 0.0
	for memory_id in state.owned_memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		for modifier in memory.get("conditional_modifiers", []):
			if typeof(modifier) != TYPE_DICTIONARY:
				continue
			if str(modifier.get("stat", "")) != stat:
				continue
			var condition := str(modifier.get("condition", ""))
			if not condition.begins_with("%s:" % prefix):
				continue
			var tag := condition.get_slice(":", 1)
			if _tag_list_has(tags, tag):
				percent_add += float(modifier.get("value", 0.0))
	return max(0.0, 1.0 + percent_add)


func _apply_enemy_battle_start_mechanics(enemy: Dictionary) -> void:
	for mechanic in enemy.get("mechanics", []):
		if typeof(mechanic) != TYPE_DICTIONARY:
			continue
		if str(mechanic.get("timing", "")) != "battle_start":
			continue
		if not _mechanic_condition_passes(mechanic):
			continue
		var effect: Dictionary = mechanic.get("effect", {})
		if str(effect.get("type", "")) == "hp_percent_add":
			var max_hp := int(enemy.get("max_hp", enemy.get("current_hp", 1)))
			enemy.current_hp = max(1, int(round(float(max_hp) * (1.0 + float(effect.get("value", 0.0))))))
		_log(str(mechanic.get("log", "")))


func _build_memory_interval_timers() -> Array[Dictionary]:
	var timers: Array[Dictionary] = []
	for memory_id in state.owned_memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		for trigger in memory.get("triggers", []):
			if typeof(trigger) != TYPE_DICTIONARY:
				continue
			if str(trigger.get("timing", "")) != "interval":
				continue
			timers.append({
				"memory_id": memory_id,
				"trigger": trigger,
				"elapsed": 0.0,
			})
	return timers


func _build_enemy_interval_timers(enemy: Dictionary) -> Array[Dictionary]:
	var timers: Array[Dictionary] = []
	for mechanic in enemy.get("mechanics", []):
		if typeof(mechanic) != TYPE_DICTIONARY:
			continue
		if str(mechanic.get("timing", "")) != "interval":
			continue
		if not _mechanic_condition_passes(mechanic):
			continue
		timers.append({
			"mechanic": mechanic,
			"elapsed": 0.0,
		})
	return timers


func _tick_memory_intervals(timers: Array[Dictionary], delta: float, stats: Dictionary) -> void:
	for timer in timers:
		timer.elapsed = float(timer.elapsed) + delta
		var trigger: Dictionary = timer.trigger
		var interval := float(trigger.get("interval_seconds", 1.0))
		if float(timer.elapsed) + 0.0001 < interval:
			continue
		timer.elapsed = float(timer.elapsed) - interval
		var effect: Dictionary = trigger.get("effect", {})
		if str(effect.get("type", "")) == "heal_flat":
			var healed: int = state.heal_flat(int(effect.get("value", 0)), stats)
			if healed > 0:
				_log(str(trigger.get("log", "恢复 %d 点生命。" % healed)))
				_stage({
					"type": "memory_heal",
					"memory_id": str(timer.memory_id),
					"amount": healed,
					"player_hp": state.hp,
				})


func _tick_enemy_intervals(enemy: Dictionary, timers: Array[Dictionary], delta: float) -> void:
	for timer in timers:
		timer.elapsed = float(timer.elapsed) + delta
		var mechanic: Dictionary = timer.mechanic
		var interval := float(mechanic.get("interval_seconds", 1.0))
		if float(timer.elapsed) + 0.0001 < interval:
			continue
		timer.elapsed = float(timer.elapsed) - interval
		var effect: Dictionary = mechanic.get("effect", {})
		var effect_type := str(effect.get("type", ""))
		if effect_type == "next_attack_damage_multiplier":
			enemy.next_attack_multiplier = float(effect.get("value", 1.0))
			_log(str(mechanic.get("log", "")))
			_stage({
				"type": "enemy_charge",
				"enemy_name": _enemy_name(enemy),
				"message": str(mechanic.get("log", "")),
				"enemy_tags": _string_array(enemy.get("tags", [])),
			})
		elif effect_type == "try_fade_non_core_memory":
			_log("%s（MVP 暂记录为战斗压力，不实际淡化记忆。）" % str(mechanic.get("log", "")))
			_stage({
				"type": "boss_pressure",
				"enemy_name": _enemy_name(enemy),
				"message": str(mechanic.get("log", "")),
				"enemy_tags": _string_array(enemy.get("tags", [])),
			})


func _check_enemy_hp_mechanics(enemy: Dictionary) -> void:
	var triggered: Dictionary = enemy.get("triggered_mechanics", {})
	for mechanic in enemy.get("mechanics", []):
		if typeof(mechanic) != TYPE_DICTIONARY:
			continue
		if str(mechanic.get("timing", "")) != "hp_below":
			continue
		var mechanic_id := str(mechanic.get("id", ""))
		if bool(mechanic.get("once", false)) and triggered.has(mechanic_id):
			continue
		var max_hp: int = max(1, int(enemy.get("max_hp", 1)))
		if float(enemy.get("current_hp", max_hp)) / float(max_hp) > float(mechanic.get("threshold", 0.0)):
			continue
		var effect: Dictionary = mechanic.get("effect", {})
		if str(effect.get("type", "")) == "stat_add":
			var stat := str(effect.get("stat", ""))
			if stat == "def":
				enemy.current_def = int(enemy.get("current_def", enemy.get("def", 0))) + int(effect.get("value", 0))
		triggered[mechanic_id] = true
		enemy.triggered_mechanics = triggered
		_log(str(mechanic.get("log", "")))
		_stage({
			"type": "enemy_guard",
			"enemy_name": _enemy_name(enemy),
			"message": str(mechanic.get("log", "")),
			"enemy_tags": _string_array(enemy.get("tags", [])),
		})


func _apply_post_battle_triggers() -> void:
	var stats: Dictionary = state.derived_stats(registry)
	for memory_id in state.owned_memory_ids:
		var memory: Dictionary = registry.memories.get(memory_id, {})
		for trigger in memory.get("triggers", []):
			if typeof(trigger) != TYPE_DICTIONARY:
				continue
			if str(trigger.get("timing", "")) != "post_battle":
				continue
			var effect: Dictionary = trigger.get("effect", {})
			if str(effect.get("type", "")) == "heal_flat":
				var healed: int = state.heal_flat(int(effect.get("value", 0)), stats)
				if healed > 0:
					_log(str(trigger.get("log", "战后恢复 %d 点生命。" % healed)))
					_stage({
						"type": "memory_heal",
						"memory_id": memory_id,
						"amount": healed,
						"player_hp": state.hp,
					})


func _apply_defeat_recovery() -> void:
	var stats: Dictionary = state.derived_stats(registry)
	var combat: Dictionary = registry.balance.get("combat", {})
	var defeat: Dictionary = combat.get("defeat", {})
	var revive_percent := float(defeat.get("revive_hp_percent", 0.5))
	var max_hp := int(round(float(stats.get("max_hp", 120))))
	state.hp = max(1, int(round(float(max_hp) * revive_percent)))
	var message := "濒死回退：勇者重新站起，生命恢复到 %d。继续前进会让记忆变得不稳定。" % state.hp
	_log(message)
	state.world_feedback_history.append(message)
	_stage({
		"type": "revive",
		"player_hp": state.hp,
	})


func _mechanic_condition_passes(mechanic: Dictionary) -> bool:
	if not mechanic.has("condition"):
		return true
	var condition := str(mechanic.condition)
	if condition.begins_with("has_memory:"):
		return state.has_memory(condition.trim_prefix("has_memory:"))
	if condition.begins_with("not_has_memory:"):
		return not state.has_memory(condition.trim_prefix("not_has_memory:"))
	if condition.begins_with("has_flag:"):
		return state.has_flag(condition.trim_prefix("has_flag:"))
	if condition.begins_with("not_has_flag:"):
		return not state.has_flag(condition.trim_prefix("not_has_flag:"))
	return false


func _parse_enemy_ids(text: String) -> Array[String]:
	var result: Array[String] = []
	for raw_id in text.split(",", false):
		var enemy_id := raw_id.strip_edges()
		if not enemy_id.is_empty():
			result.append(enemy_id)
	return result


func _reward_text(rewards: Dictionary) -> String:
	var parts: Array[String] = []
	if int(rewards.get("exp", 0)) > 0:
		parts.append("经验 +%d" % int(rewards.exp))
	if int(rewards.get("gold", 0)) > 0:
		parts.append("金币 +%d" % int(rewards.gold))
	if int(rewards.get("memory_fragment", 0)) > 0:
		parts.append("记忆碎片 +%d" % int(rewards.memory_fragment))
	if int(rewards.get("levels_gained", 0)) > 0:
		parts.append("等级 +%d" % int(rewards.levels_gained))
	if bool(rewards.get("mvp_ending", false)):
		parts.append("新的道路已开启")
	if parts.is_empty():
		return "战斗结束。"
	return "战斗奖励：%s。" % "，".join(parts)


func _enemy_name(enemy: Dictionary) -> String:
	return str(enemy.get("log_name", enemy.get("name", enemy.get("id", "敌人"))))


func _has_tag(enemy: Dictionary, tag: String) -> bool:
	return _tag_list_has(enemy.get("tags", []), tag)


func _string_array(values) -> Array[String]:
	var result: Array[String] = []
	if typeof(values) != TYPE_ARRAY:
		return result
	for value in values:
		result.append(str(value))
	return result


func _tag_list_has(tags, tag: String) -> bool:
	if typeof(tags) != TYPE_ARRAY:
		return false
	for current_tag in tags:
		if str(current_tag) == tag:
			return true
	return false


func _log(message: String) -> void:
	if message.strip_edges().is_empty():
		return
	logs.append(message)


func _stage(event: Dictionary) -> void:
	if timeline.size() >= 48:
		return
	timeline.append(event)
