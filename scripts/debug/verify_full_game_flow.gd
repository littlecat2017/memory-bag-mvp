extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")
const RunControllerScript := preload("res://scripts/runtime/run_controller.gd")
const BattleRunnerScript := preload("res://scripts/runtime/battle_runner.gd")
const EndingRunnerScript := preload("res://scripts/runtime/ending_runner.gd")

var registry
var state
var player
var run
var battle
var ending_runner


func _init() -> void:
	registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	state = GameStateScript.new()
	state.configure_from_balance(registry.balance)
	player = ScriptPlayerScript.new()
	player.setup(registry, state)
	run = RunControllerScript.new()
	run.setup(registry, state)
	battle = BattleRunnerScript.new()
	battle.setup(registry, state)
	ending_runner = EndingRunnerScript.new()
	ending_runner.setup(registry, state)

	_run_standard_path()
	print("verify_full_game_flow: ok; ending=%s hp=%d gold=%d bag=%s" % [
		state.current_ending_id,
		state.hp,
		state.gold,
		state.bag_summary(registry),
	])
	quit(0)


func _run_standard_path() -> void:
	player.start("P0001", "P0037")
	_advance_to_choice("P0034")
	player.select_choice(0)
	_advance_to_segment_end()
	_expect(state.has_memory("mem_mothers_soup"), "standard start should keep soup")
	_expect(state.has_memory("mem_my_name"), "standard start should keep name")

	run.start_chapter("forest")
	_expect(run.chapter_id == "forest", "forest chapter should start")
	_run_script_segment("F0001", "F0002")
	_run_battle_event("F0003")

	_run_script_segment("F0004", "F0011C", "F0010", 0)
	_expect(state.has_pending_memory(), "F0010 should request replacement with full bag")
	state.accept_pending_by_discard("mem_mothers_soup", registry)
	player.finish_memory_replacement()
	_advance_to_segment_end()
	_expect(state.has_memory("mem_someone_waits"), "should gain someone waits")
	_expect(state.has_discarded("mem_mothers_soup"), "should discard soup")

	_run_script_segment("F0012", "F0022B", "F0021", 1)
	_expect(not state.has_memory("mem_no_more_explaining"), "choosing no should skip no more explaining")

	_run_battle_event("F0023")

	_run_script_segment("F0024", "F0035C", "F0034", 0)
	_expect(state.has_memory("mem_my_name"), "refusing name sacrifice should keep name")
	_expect(not state.has_memory("mem_empty_nameplate"), "refusing name sacrifice should not gain empty nameplate")

	_run_battle_event("F0036")
	_run_script_segment("F0037", "F0040")
	_expect(state.has_pending_memory(), "F0038 should request replacement for empty nameplate when bag is full")
	state.accept_pending_by_discard("mem_someone_waits", registry)
	player.finish_memory_replacement()
	_advance_to_segment_end()
	_expect(state.owned_memory_ids.size() <= state.capacity(), "bag should not exceed capacity after empty nameplate")
	_expect(state.has_memory("mem_empty_nameplate"), "should gain empty nameplate through replacement")

	var ending: Dictionary = ending_runner.evaluate_mvp_ending()
	_expect(str(ending.get("id", "")) == "mvp_named_with_reason", "should reach named-with-reason ending")
	_expect(ending.get("lines", []).size() > 0, "ending should have playable lines")


func _run_script_segment(start_event_id: String, stop_event_id: String, choice_event_id: String = "", option_index: int = -1) -> void:
	player.start(start_event_id, stop_event_id)
	if choice_event_id.is_empty():
		_advance_to_segment_end()
		return
	_advance_to_choice(choice_event_id)
	player.select_choice(option_index)


func _advance_to_choice(choice_event_id: String, max_steps: int = 100) -> void:
	var steps := 0
	while steps < max_steps:
		steps += 1
		if state.current_event_id == choice_event_id:
			_expect(str(player.current_event().get("type", "")) == "choice", "%s should be a choice" % choice_event_id)
			return
		_expect(not state.current_event_id.is_empty(), "expected %s before segment ended" % choice_event_id)
		player.advance()
	_fail("timed out waiting for choice %s, current=%s" % [choice_event_id, state.current_event_id])


func _advance_to_segment_end(max_steps: int = 100) -> void:
	var steps := 0
	while steps < max_steps:
		steps += 1
		if state.current_event_id.is_empty():
			return
		_expect(str(player.current_event().get("type", "")) != "choice", "unexpected unresolved choice: %s" % state.current_event_id)
		player.advance()
	_fail("timed out waiting for segment end, current=%s" % state.current_event_id)


func _run_battle_event(event_id: String) -> void:
	var event: Dictionary = registry.script_events.get(event_id, {})
	_expect(not event.is_empty(), "battle event should exist: %s" % event_id)
	var result: Dictionary = battle.run_event(event)
	_expect(bool(result.get("victory", false)), "battle should be victorious: %s" % event_id)
	_expect(state.seen_event_ids.has(event_id), "battle should mark event seen: %s" % event_id)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)


func _fail(message: String) -> void:
	push_error("verify_full_game_flow: %s" % message)
	quit(1)
