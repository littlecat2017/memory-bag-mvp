extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")


func _init() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return

	_verify_standard_start(registry)
	_verify_light_start(registry)
	print("verify_prologue: ok")
	quit(0)


func _verify_standard_start(registry) -> void:
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)

	var player = ScriptPlayerScript.new()
	player.setup(registry, state)
	player.start("P0001")

	var guard := 0
	while guard < 100 and state.current_event_id != "P0034":
		guard += 1
		player.advance()
	if state.current_event_id != "P0034":
		_fail("expected P0034, got %s" % state.current_event_id)
		return

	player.select_choice(0)
	if state.current_event_id != "P0035A":
		_fail("standard start should go to P0035A, got %s" % state.current_event_id)
		return

	player.advance()
	if state.current_event_id != "P0036":
		_fail("branch should merge to P0036, got %s" % state.current_event_id)
		return

	player.advance()
	if state.current_event_id != "P0037":
		_fail("expected P0037, got %s" % state.current_event_id)
		return

	var expected := [
		"mem_mothers_soup",
		"mem_wooden_sword",
		"mem_reason_to_depart",
		"mem_my_name",
	]
	for memory_id in expected:
		if not state.has_memory(memory_id):
			_fail("missing expected memory after standard start: %s" % memory_id)
			return
	if state.owned_memory_ids.size() != expected.size():
		_fail("unexpected owned memory count: %d" % state.owned_memory_ids.size())
		return

	print("verify_prologue standard: event=P0037; bag=%s" % state.bag_summary(registry))


func _verify_light_start(registry) -> void:
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)

	var player = ScriptPlayerScript.new()
	player.setup(registry, state)
	player.start("P0001")

	var guard := 0
	while guard < 100 and state.current_event_id != "P0034":
		guard += 1
		player.advance()
	if state.current_event_id != "P0034":
		_fail("light start expected P0034, got %s" % state.current_event_id)
		return

	player.select_choice(1)
	if state.current_event_id != "P0035B":
		_fail("light start should go to P0035B, got %s" % state.current_event_id)
		return

	player.advance()
	if state.current_event_id != "P0036":
		_fail("light start branch should merge to P0036, got %s" % state.current_event_id)
		return

	player.advance()
	if state.current_event_id != "P0037":
		_fail("light start expected P0037, got %s" % state.current_event_id)
		return

	if state.has_memory("mem_mothers_soup"):
		_fail("light start should not own mem_mothers_soup")
		return
	if not state.has_discarded("mem_mothers_soup"):
		_fail("light start should discard mem_mothers_soup")
		return
	if not state.has_flag("start_without_soup"):
		_fail("light start should set start_without_soup")
		return
	for memory_id in ["mem_wooden_sword", "mem_reason_to_depart", "mem_my_name"]:
		if not state.has_memory(memory_id):
			_fail("light start missing expected memory: %s" % memory_id)
			return

	print("verify_prologue light: event=P0037; bag=%s" % state.bag_summary(registry))


func _fail(message: String) -> void:
	push_error("verify_prologue: %s" % message)
	quit(1)
