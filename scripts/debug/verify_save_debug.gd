extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const RunControllerScript := preload("res://scripts/runtime/run_controller.gd")
const ScriptPlayerScript := preload("res://scripts/runtime/script_player.gd")
const SaveManagerScript := preload("res://scripts/runtime/save_manager.gd")
const MainScript := preload("res://scripts/runtime/main.gd")

const VERIFY_SAVE_PATH := "user://verify_save_debug.json"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	_verify_save_roundtrip(registry)
	await _verify_debug_panel_jumps()
	print("verify_save_debug: ok")
	quit(0)


func _verify_save_roundtrip(registry) -> void:
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)
	state.gain_memory("mem_wooden_sword")
	state.gain_memory("mem_reason_to_depart")
	state.discard_memory("mem_mothers_soup")
	state.flags["test_flag"] = true
	state.route = "debug_route"
	state.hp = 77
	state.gold = 26
	state.record_choice("P0034", "标准开局", "P0035A")
	state.remember_event("F0003")

	var run = RunControllerScript.new()
	run.setup(registry, state)
	run.start_chapter("forest")
	run.progress = 550.0
	run.triggered_node_ids["forest_intro"] = true
	run.triggered_node_ids["forest_battle_01"] = true
	run.is_running = false

	var player = ScriptPlayerScript.new()
	player.setup(registry, state)
	player.start("F0012", "F0022B")

	var save_manager = SaveManagerScript.new()
	var ui_context := {
		"active_script_node_id": "forest_camp_and_memory",
		"active_ending_index": -1,
	}
	if not save_manager.save_to_file(VERIFY_SAVE_PATH, state, run, player, ui_context):
		_fail(save_manager.last_error)
		return

	var loaded_state = GameStateScript.new()
	loaded_state.configure_from_balance(registry.balance)
	var loaded_run = RunControllerScript.new()
	loaded_run.setup(registry, loaded_state)
	var loaded_player = ScriptPlayerScript.new()
	loaded_player.setup(registry, loaded_state)
	var loaded_ui: Dictionary = save_manager.load_from_file(VERIFY_SAVE_PATH, loaded_state, loaded_run, loaded_player)
	if save_manager.last_error != "":
		_fail(save_manager.last_error)
		return
	if not loaded_state.has_memory("mem_wooden_sword") or not loaded_state.has_discarded("mem_mothers_soup"):
		_fail("save should restore memory ownership and discarded memories")
		return
	if loaded_state.hp != 77 or loaded_state.gold != 26 or not loaded_state.has_flag("test_flag"):
		_fail("save should restore hp, gold, and flags")
		return
	if loaded_run.chapter_id != "forest" or int(loaded_run.progress) != 550 or not loaded_run.triggered_node_ids.has("forest_battle_01"):
		_fail("save should restore run progress and triggered nodes")
		return
	if loaded_player.active_stop_event_id != "F0022B" or loaded_state.current_event_id != "F0012":
		_fail("save should restore script player state")
		return
	if str(loaded_ui.get("active_script_node_id", "")) != "forest_camp_and_memory":
		_fail("save should restore ui context")


func _verify_debug_panel_jumps() -> void:
	var main = MainScript.new()
	get_root().add_child(main)
	await process_frame
	var expected := {
		"P0034": "P0034",
		"F0010": "F0010",
		"F0021": "F0021",
		"F0034": "F0034",
		"F0040": "F0040",
	}
	for target_id in expected.keys():
		main.debug_jump_to_event(str(target_id))
		if main.game_state.current_event_id != expected[target_id]:
			main.queue_free()
			_fail("debug jump %s expected current event %s, got %s" % [
				target_id,
				expected[target_id],
				main.game_state.current_event_id,
			])
			return
	main.queue_free()


func _fail(message: String) -> void:
	push_error("verify_save_debug: %s" % message)
	quit(1)
