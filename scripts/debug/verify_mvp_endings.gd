extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")
const EndingRunnerScript := preload("res://scripts/runtime/ending_runner.gd")


func _init() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	_verify_all_mvp_endings(registry)
	_verify_boss_name_choice(registry)
	_verify_script_segment_stops_at_branch_end(registry)
	print("verify_mvp_endings: ok")
	quit(0)


func _new_state(registry):
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)
	return state


func _new_script_player(registry, state):
	var player = ScriptPlayerScript.new()
	player.setup(registry, state)
	return player


func _new_ending_runner(registry, state):
	var runner = EndingRunnerScript.new()
	runner.setup(registry, state)
	return runner


func _verify_all_mvp_endings(registry) -> void:
	_expect_ending(registry, true, true, "mvp_named_with_reason")
	_expect_ending(registry, true, false, "mvp_named_without_reason")
	_expect_ending(registry, false, true, "mvp_nameless_with_reason")
	_expect_ending(registry, false, false, "mvp_nameless_without_reason")


func _expect_ending(registry, keep_name: bool, keep_reason: bool, ending_id: String) -> void:
	var state = _new_state(registry)
	if keep_name:
		state.gain_memory("mem_my_name")
	else:
		state.discard_memory("mem_my_name")
	if keep_reason:
		state.gain_memory("mem_reason_to_depart")
	else:
		state.discard_memory("mem_reason_to_depart")
	var runner = _new_ending_runner(registry, state)
	var result: Dictionary = runner.evaluate_mvp_ending()
	if str(result.get("id", "")) != ending_id:
		_fail("expected ending %s, got %s" % [ending_id, result.get("id", "")])
		return
	if result.get("lines", []).size() != 2:
		_fail("ending %s should have exactly 2 lines from mvp_endings.json" % ending_id)
		return
	if state.current_ending_id != ending_id or not state.ending_history.has(ending_id):
		_fail("state should remember ending %s" % ending_id)


func _verify_boss_name_choice(registry) -> void:
	var state = _new_state(registry)
	for memory_id in ["mem_mothers_soup", "mem_wooden_sword", "mem_reason_to_depart", "mem_my_name"]:
		state.gain_memory(memory_id)
	var player = _new_script_player(registry, state)
	player.start("F0034", "F0035B")
	if state.current_event_id != "F0034":
		_fail("expected F0034 boss choice, got %s" % state.current_event_id)
		return
	player.select_choice(1)
	if state.has_memory("mem_my_name"):
		_fail("giving name to hunter should discard mem_my_name")
		return
	if not state.has_memory("mem_empty_nameplate"):
		_fail("giving name to hunter should gain mem_empty_nameplate")
		return
	if not state.has_flag("gave_name_to_hunter"):
		_fail("giving name to hunter should set gave_name_to_hunter")
		return
	if state.display_name != state.fallback_display_name:
		_fail("giving name to hunter should erase display name")
		return
	if state.current_event_id != "F0035B":
		_fail("giving name to hunter should continue to F0035B, got %s" % state.current_event_id)


func _verify_script_segment_stops_at_branch_end(registry) -> void:
	var state = _new_state(registry)
	for memory_id in ["mem_mothers_soup", "mem_wooden_sword", "mem_reason_to_depart", "mem_my_name"]:
		state.gain_memory(memory_id)
	var player = _new_script_player(registry, state)
	player.start("F0034", "F0035C")
	player.select_choice(0)
	if state.current_event_id != "F0035A":
		_fail("refuse name should go to F0035A, got %s" % state.current_event_id)
		return
	player.advance()
	if not state.current_event_id.is_empty():
		_fail("boss choice segment should stop after F0035A branch merge, got %s" % state.current_event_id)


func _fail(message: String) -> void:
	push_error("verify_mvp_endings: %s" % message)
	quit(1)
