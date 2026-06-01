extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const GameStateScript := preload("res://scripts/runtime/game_state.gd")
const RunControllerScript := preload("res://scripts/runtime/run_controller.gd")

var triggered: Array[String] = []


func _init() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	var state = GameStateScript.new()
	state.configure_from_balance(registry.balance)
	var run = RunControllerScript.new()
	run.setup(registry, state)
	run.node_triggered.connect(_on_node_triggered)
	run.start_chapter("forest")
	_expect_last("forest_intro")
	_mark_seen_for_last_node(registry, state)
	run.resume()
	run.debug_jump_to(150)
	_expect_last("forest_battle_01")
	_mark_seen_for_last_node(registry, state)
	run.resume()
	run.debug_jump_to(300)
	_expect_last("forest_memory_choice_01")
	_mark_seen_for_last_node(registry, state)
	run.resume()
	run.debug_jump_to(550)
	_expect_last("forest_camp_and_memory")
	_mark_seen_for_last_node(registry, state)
	run.resume()
	run.debug_jump_to(700)
	_expect_last("forest_battle_02")
	_mark_seen_for_last_node(registry, state)
	run.resume()
	run.debug_jump_to(850)
	_expect_last("forest_shrine_and_boss_choice")
	_mark_seen_for_last_node(registry, state)
	run.resume()
	run.debug_jump_to(1000)
	_expect_last("forest_boss")
	state.remember_event("F0036")
	run.resume()
	run.debug_jump_to(1000)
	_expect_last("forest_after_boss")
	print("verify_run_flow: ok; triggered=%s" % ", ".join(triggered))
	quit(0)


func _on_node_triggered(node: Dictionary) -> void:
	triggered.append(str(node.get("node_id", "")))


func _expect_last(node_id: String) -> void:
	if triggered.is_empty() or triggered[-1] != node_id:
		_fail("expected node %s, got %s" % [node_id, "none" if triggered.is_empty() else triggered[-1]])


func _mark_seen_for_last_node(registry, state) -> void:
	var node_id: String = triggered[-1]
	for chapter in registry.chapter_flow.get("chapters", []):
		for node in chapter.get("nodes", []):
			if typeof(node) == TYPE_DICTIONARY and str(node.get("node_id", "")) == node_id:
				if node.has("event_id"):
					state.remember_event(str(node.event_id))
				if node.has("end_event_id"):
					state.remember_event(str(node.end_event_id))
				return


func _fail(message: String) -> void:
	push_error("verify_run_flow: %s" % message)
	quit(1)
