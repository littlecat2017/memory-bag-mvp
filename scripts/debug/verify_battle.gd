extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const BattleRunnerScript := preload("res://scripts/runtime/battle_runner.gd")


func _init() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	_verify_wooden_sword_damage(registry)
	_verify_someone_waits_heal(registry)
	_verify_empty_nameplate_damage(registry)
	_verify_empty_nameplate_boss_damage(registry)
	_verify_silent_damage_reduction(registry)
	_verify_battle_rewards(registry)
	_verify_battle_timeline(registry)
	print("verify_battle: ok")
	quit(0)


func _new_state(registry):
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)
	return state


func _new_runner(registry, state):
	var runner = BattleRunnerScript.new()
	runner.setup(registry, state)
	return runner


func _verify_wooden_sword_damage(registry) -> void:
	var base_state = _new_state(registry)
	var base_runner = _new_runner(registry, base_state)
	var base_damage: int = base_runner.preview_player_attack_damage("enemy_hollow_wolves")

	var sword_state = _new_state(registry)
	sword_state.gain_memory("mem_wooden_sword")
	var sword_runner = _new_runner(registry, sword_state)
	var sword_damage: int = sword_runner.preview_player_attack_damage("enemy_hollow_wolves")

	if sword_damage <= base_damage:
		_fail("wooden sword should increase damage: base=%d sword=%d" % [base_damage, sword_damage])


func _verify_someone_waits_heal(registry) -> void:
	var state = _new_state(registry)
	state.hp = 60
	state.gain_memory("mem_someone_waits")
	var runner = _new_runner(registry, state)
	var event: Dictionary = registry.script_events.get("F0003", {})
	var result: Dictionary = runner.run_event(event)
	if not bool(result.get("victory", false)):
		_fail("someone waits battle should still be won")
		return
	if not _logs_contain(result.get("logs", []), "有人等我"):
		_fail("someone waits should log interval healing")


func _verify_empty_nameplate_damage(registry) -> void:
	var base_state = _new_state(registry)
	var base_runner = _new_runner(registry, base_state)
	var base_damage: int = base_runner.preview_player_attack_damage("enemy_nameless_deer")

	var plate_state = _new_state(registry)
	plate_state.gain_memory("mem_empty_nameplate")
	var plate_runner = _new_runner(registry, plate_state)
	var plate_damage: int = plate_runner.preview_player_attack_damage("enemy_nameless_deer")

	if plate_damage <= base_damage:
		_fail("empty nameplate should increase damage against nameless: base=%d plate=%d" % [base_damage, plate_damage])


func _verify_empty_nameplate_boss_damage(registry) -> void:
	var base_state = _new_state(registry)
	var base_runner = _new_runner(registry, base_state)
	var base_damage: int = base_runner.preview_player_attack_damage("boss_nameless_hunter")

	var plate_state = _new_state(registry)
	plate_state.gain_memory("mem_empty_nameplate")
	var plate_runner = _new_runner(registry, plate_state)
	var plate_damage: int = plate_runner.preview_player_attack_damage("boss_nameless_hunter")

	if plate_damage <= base_damage:
		_fail("empty nameplate should increase damage against boss: base=%d plate=%d" % [base_damage, plate_damage])


func _verify_silent_damage_reduction(registry) -> void:
	var base_state = _new_state(registry)
	var base_runner = _new_runner(registry, base_state)
	var base_damage: int = base_runner.preview_enemy_attack_damage("enemy_hollow_warden")

	var quiet_state = _new_state(registry)
	quiet_state.gain_memory("mem_no_more_explaining")
	var quiet_runner = _new_runner(registry, quiet_state)
	var quiet_damage: int = quiet_runner.preview_enemy_attack_damage("enemy_hollow_warden")

	if quiet_damage >= base_damage:
		_fail("no more explaining should reduce silent damage: base=%d reduced=%d" % [base_damage, quiet_damage])


func _verify_battle_rewards(registry) -> void:
	var state = _new_state(registry)
	for memory_id in ["mem_mothers_soup", "mem_wooden_sword", "mem_reason_to_depart", "mem_my_name"]:
		state.gain_memory(memory_id)
	var runner = _new_runner(registry, state)
	var event: Dictionary = registry.script_events.get("F0003", {})
	var result: Dictionary = runner.run_event(event)
	if not bool(result.get("victory", false)):
		_fail("F0003 should be won with standard start memories")
		return
	if not state.seen_event_ids.has("F0003"):
		_fail("battle event should be remembered after completion")
		return
	if state.gold != 8:
		_fail("gold reward should be 8 after F0003, got %d" % state.gold)
		return
	if state.memory_fragment != 1:
		_fail("memory fragment reward should be 1 after F0003, got %d" % state.memory_fragment)
		return
	if int(result.get("rewards", {}).get("exp", 0)) != 18:
		_fail("exp reward should be 18 after F0003")


func _verify_battle_timeline(registry) -> void:
	var state = _new_state(registry)
	for memory_id in ["mem_mothers_soup", "mem_wooden_sword", "mem_reason_to_depart", "mem_my_name"]:
		state.gain_memory(memory_id)
	var runner = _new_runner(registry, state)
	var event: Dictionary = registry.script_events.get("F0003", {})
	var result: Dictionary = runner.run_event(event)
	var timeline = result.get("timeline", [])
	if typeof(timeline) != TYPE_ARRAY or timeline.is_empty():
		_fail("battle result should include animation timeline")
		return
	if not _timeline_has(timeline, "enemy_appear"):
		_fail("timeline should include enemy appear event")
		return
	if not _timeline_has(timeline, "player_attack"):
		_fail("timeline should include player attack event")
		return
	if not _timeline_has(timeline, "enemy_defeated"):
		_fail("timeline should include enemy defeated event")
		return


func _logs_contain(values, needle: String) -> bool:
	for value in values:
		if str(value).contains(needle):
			return true
	return false


func _timeline_has(values, event_type: String) -> bool:
	for value in values:
		if typeof(value) == TYPE_DICTIONARY and str(value.get("type", "")) == event_type:
			return true
	return false


func _fail(message: String) -> void:
	push_error("verify_battle: %s" % message)
	quit(1)
