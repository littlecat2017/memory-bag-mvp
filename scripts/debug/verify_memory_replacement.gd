extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")


func _init() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	_verify_full_bag_replacement(registry)
	_verify_light_start_direct_gain(registry)
	print("verify_memory_replacement: ok")
	quit(0)


func _new_state(registry):
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)
	return state


func _new_player(registry, state):
	var player = ScriptPlayerScript.new()
	player.setup(registry, state)
	return player


func _apply_standard_start(state) -> void:
	state.gain_memory("mem_mothers_soup")
	state.gain_memory("mem_wooden_sword")
	state.gain_memory("mem_reason_to_depart")
	state.gain_memory("mem_my_name")


func _verify_full_bag_replacement(registry) -> void:
	var state = _new_state(registry)
	_apply_standard_start(state)
	var player = _new_player(registry, state)
	player.start("F0010", "F0011A")
	player.select_choice(0)
	if not state.has_pending_memory() or state.pending_memory_id != "mem_someone_waits":
		_fail("expected pending mem_someone_waits for full bag")
		return
	if state.has_memory("mem_someone_waits"):
		_fail("pending memory should not be owned before replacement")
		return
	state.accept_pending_by_discard("mem_mothers_soup", registry)
	player.finish_memory_replacement()
	if not state.has_memory("mem_someone_waits"):
		_fail("replacement should gain mem_someone_waits")
		return
	if not state.has_discarded("mem_mothers_soup"):
		_fail("replacement should discard mem_mothers_soup")
		return
	if state.current_event_id != "F0011A":
		_fail("replacement should continue to F0011A, got %s" % state.current_event_id)
		return
	if state.world_feedback_history.is_empty():
		_fail("replacement should record world feedback")
		return


func _verify_light_start_direct_gain(registry) -> void:
	var state = _new_state(registry)
	state.gain_memory("mem_wooden_sword")
	state.gain_memory("mem_reason_to_depart")
	state.gain_memory("mem_my_name")
	state.discard_memory("mem_mothers_soup")
	var player = _new_player(registry, state)
	player.start("F0010", "F0011A")
	player.select_choice(0)
	if state.has_pending_memory():
		_fail("light start should not open replacement")
		return
	if not state.has_memory("mem_someone_waits"):
		_fail("light start should directly gain mem_someone_waits")
		return
	if state.current_event_id != "F0011A":
		_fail("light start should continue to F0011A, got %s" % state.current_event_id)
		return


func _fail(message: String) -> void:
	push_error("verify_memory_replacement: %s" % message)
	quit(1)
