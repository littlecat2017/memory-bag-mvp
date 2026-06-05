extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failed := false
var battle_count := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("verify_mvp_playthrough: start")
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	await process_frame

	_expect(main.validation_errors.is_empty(), "no validation errors")
	main.start_script()
	await process_frame

	for encounter_index in range(3):
		_expect(main.current_mode == "travel", "encounter %d starts from travel" % [encounter_index + 1])
		_expect(main.opening_travel_active, "encounter %d travel is active" % [encounter_index + 1])
		await _drive_to_battle(main)
		_expect(main.current_mode == "battle", "encounter %d reaches battle" % [encounter_index + 1])
		_expect(not main.dialogue_panel.visible, "encounter %d never shows dialogue" % [encounter_index + 1])
		_expect(not main.choice_panel.visible, "encounter %d never shows choices" % [encounter_index + 1])
		_expect(not main.ending_layer.visible, "encounter %d never shows ending" % [encounter_index + 1])
		var reward_id := str(main.battle_reward_ids[0]) if not main.battle_reward_ids.is_empty() else ""
		await _resolve_battle(main)
		_expect(main.current_mode == "travel", "encounter %d victory returns to travel" % [encounter_index + 1])
		_expect(main.opening_travel_active, "encounter %d starts next travel segment" % [encounter_index + 1])
		if not reward_id.is_empty():
			_expect(main.has_memory(reward_id), "encounter %d reward enters backpack" % [encounter_index + 1])
		_expect(main.memory_grid_positions.size() == main.owned_memory_count(), "encounter %d keeps grid positions for owned memories" % [encounter_index + 1])
		battle_count += 1

	_expect(battle_count == 3, "playthrough resolves three gameplay battles")
	_expect(main.owned_memory_count() >= 7, "playthrough gains battle rewards")
	_expect(main.has_memory("mem_someone_waits"), "first reward memory is present")
	_expect(main.has_memory("mem_masters_scolding"), "second reward memory is present")
	_expect(main.has_memory("mem_abandoned_afternoon"), "third reward memory is present")
	_expect(main.current_event.is_empty(), "playthrough ends in travel without story event")
	_expect(main.selected_ending_id.is_empty(), "playthrough does not select story ending")
	_expect(main.route_id.is_empty(), "playthrough does not set story route")

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_mvp_playthrough: ok")
	print("verify_mvp_playthrough: battles=%d memories=%d" % [
		battle_count,
		main.owned_memory_count(),
	])
	quit(0)


func _drive_to_battle(main: Control) -> void:
	for _step in range(24):
		if main.current_mode == "battle":
			return
		main._update_opening_travel(0.5)
		await process_frame


func _resolve_battle(main: Control) -> void:
	for _step in range(240):
		if main.current_mode == "travel":
			return
		if main._battle_animation_active():
			main._update_actor_animations(0.05)
		else:
			main._update_battle_turn_flow(0.05)
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_mvp_playthrough: %s" % message)
