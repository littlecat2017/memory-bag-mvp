extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failed := false
var battle_count := 0
var seen_enemy_ids: Array[String] = []


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

	for encounter_index in range(10):
		_expect(main.current_mode == "travel", "encounter %d starts from travel" % [encounter_index + 1])
		_expect(main.opening_travel_active, "encounter %d travel is active" % [encounter_index + 1])
		_expect(main.current_stage_map_index == encounter_index % main.stage_background_textures.size(), "encounter %d uses expected stage map" % [encounter_index + 1])
		await _drive_to_battle(main)
		_expect(main.current_mode == "battle", "encounter %d reaches battle" % [encounter_index + 1])
		_expect(main.current_stage_map_index == encounter_index % main.stage_background_textures.size(), "encounter %d battle keeps travel stage map" % [encounter_index + 1])
		var expected_enemy_id := str(main.GAMEPLAY_ENEMY_IDS[encounter_index % main.GAMEPLAY_ENEMY_IDS.size()])
		_expect(main.battle_enemy_id == expected_enemy_id, "encounter %d uses expected enemy id" % [encounter_index + 1])
		_expect(not seen_enemy_ids.has(main.battle_enemy_id), "encounter %d enemy is not repeated in first cycle" % [encounter_index + 1])
		seen_enemy_ids.append(main.battle_enemy_id)
		_expect(main.enemy_art.texture == main.enemy_textures[main.battle_enemy_id], "encounter %d displays its enemy texture" % [encounter_index + 1])
		_expect(not main.dialogue_panel.visible, "encounter %d never shows dialogue" % [encounter_index + 1])
		_expect(not main.choice_panel.visible, "encounter %d never shows choices" % [encounter_index + 1])
		_expect(not main.ending_layer.visible, "encounter %d never shows ending" % [encounter_index + 1])
		await _resolve_battle(main)
		_expect(main.current_mode == "travel", "encounter %d victory returns to travel" % [encounter_index + 1])
		_expect(main.opening_travel_active, "encounter %d starts next travel segment" % [encounter_index + 1])
		_expect(main.memory_grid_positions.size() == main.owned_memory_count(), "encounter %d keeps grid positions for owned memories" % [encounter_index + 1])
		battle_count += 1

	_expect(battle_count == 10, "playthrough resolves ten gameplay battles")
	_expect(seen_enemy_ids.size() == 10, "playthrough sees ten enemy ids")
	_expect(main.player_level == 4, "playthrough levels up every three battles")
	_expect(main.battle_experience == 1, "playthrough keeps remaining battle experience")
	_expect(main.owned_memory_count() >= 7, "playthrough gains three level rewards")
	_expect(main.last_reward_notice.find("经验") >= 0, "playthrough reports remaining experience after non-level battle")
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
