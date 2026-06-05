extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const PROTECTED_MEMORIES := [
	"mem_mothers_soup",
	"mem_reason_to_depart",
	"mem_my_name",
]
const CHOICE_TARGETS := {
	"P0034": "P0035A",
	"F0010": "F0011A",
	"F0021": "F0022B",
	"F0034": "F0035A",
	"M0010": "M0011B",
	"M0017": "M0018B",
	"M0020": "M0021B",
	"C0011": "C0012D",
	"C0022": "C0023B",
	"C0029": "C0030D",
	"K0020": "K0021A",
	"K0026": "EVAL_ENDING",
}

var failed := false
var visited_event_ids: Array[String] = []
var battle_count := 0
var replacement_count := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("verify_mvp_playthrough: start")
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	await process_frame

	main.start_script()
	for _step in range(600):
		var event_id := str(main.current_event.get("id", ""))
		if not event_id.is_empty() and (visited_event_ids.is_empty() or visited_event_ids[visited_event_ids.size() - 1] != event_id):
			visited_event_ids.append(event_id)
		if main.current_mode == "ending" and event_id.begins_with("E"):
			break
		match main.current_mode:
			"battle":
				if main._battle_animation_active():
					main._update_actor_animations(0.05)
				elif not main.battle_resolved:
					battle_count += 1
					main.advance_battle()
				else:
					main.advance_battle()
			"choice":
				_choose_mvp_option(main)
			"memory_replace":
				replacement_count += 1
				main.replace_memory_at(_replacement_slot(main))
			"dialogue", "travel":
				main.advance_script()
			"ending":
				break
			_:
				main.advance_script()
		await process_frame

	_expect(main.current_mode == "ending", "playthrough reaches ending mode")
	_expect(str(main.current_event.get("id", "")) == "E0001", "playthrough reaches hero ending event E0001")
	_expect(main.selected_ending_id == "hero", "playthrough selects hero ending")
	_expect(main.route_id == "kill_demon", "playthrough records kill_demon route")
	_expect(main.has_memory("mem_reason_to_depart"), "playthrough preserves reason to depart")
	_expect(main.has_memory("mem_my_name"), "playthrough preserves hero name")
	_expect(battle_count >= 8, "playthrough resolves major source-script battles")
	_expect(main._memory_grid_size("mem_wooden_sword") == Vector2i(4, 1), "playthrough uses spatial inventory item sizes")
	_expect(main.memory_grid_positions.size() == main.owned_memory_count(), "playthrough keeps grid positions for owned memories")
	_expect(visited_event_ids.has("K0026"), "playthrough reaches final choice")
	_expect(visited_event_ids.has("M0032"), "playthrough reaches mountain reward memory")
	_expect(visited_event_ids.has("C0034"), "playthrough reaches city reward memory")
	_expect(main.ending_summary_label.text.find("英雄结局") >= 0, "ending summary shows source-script hero ending text")
	_expect(main.ending_memory_label.text.find("最终背包") >= 0, "ending memory panel shows final backpack")

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_mvp_playthrough: ok")
	print("verify_mvp_playthrough: events=%d battles=%d replacements=%d ending=%s" % [
		visited_event_ids.size(),
		battle_count,
		replacement_count,
		main.selected_ending_id,
	])
	quit(0)


func _choose_mvp_option(main: Control) -> void:
	var event_id := str(main.current_event.get("id", ""))
	var target := str(CHOICE_TARGETS.get(event_id, ""))
	if target.is_empty():
		main.choose_option(0)
		return
	for index in range(main.available_choice_options.size()):
		var option: Dictionary = main.available_choice_options[index]
		if str(option.get("target", "")) == target:
			main.choose_option(index)
			return
	main.choose_option(0)


func _replacement_slot(main: Control) -> int:
	for index in range(main.owned_memory_ids.size()):
		var memory_id := str(main.owned_memory_ids[index])
		if not PROTECTED_MEMORIES.has(memory_id):
			return index
	return 0


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_mvp_playthrough: %s" % message)
