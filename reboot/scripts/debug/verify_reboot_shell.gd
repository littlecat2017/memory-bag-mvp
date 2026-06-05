extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("verify_reboot_shell: start")
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	await process_frame

	_expect(main.validation_errors.is_empty(), "no validation errors")
	_expect(main.loaded_event_count() == 0, "story events are not loaded in gameplay-only MVP")
	_expect(main.loaded_memory_count() >= 16, "loads standalone memory definitions")
	_expect(main.memories.has("mem_mothers_soup"), "loads required initial memory")
	_expect(main.memories.has("mem_rusty_victory"), "loads battle reward memory")
	_expect(main.screen_background_art.texture != null, "loads gameplay shell art")
	_expect(main.title_background_art.texture != null, "loads title background art")
	_expect(main.hero_art.texture != null, "loads hero art")
	_expect(main.enemy_art.texture != null, "loads enemy art")
	_expect(main.memory_icons_texture != null, "loads memory icon atlas")

	main.show_mode("title")
	_expect(main.title_layer.visible, "title mode shows title layer")
	_expect(not main.operation_tray.visible, "title mode hides operation tray")
	_expect(not main.dialogue_panel.visible, "title mode hides dialogue panel")
	_expect(not main.choice_panel.visible, "title mode hides choice panel")
	_expect(not main.ending_layer.visible, "title mode hides ending layer")
	_expect(abs(main.title_start_button.get_global_rect().get_center().x - 640.0) <= 1.0, "title start button is centered")
	_expect(abs(main.title_quit_button.get_global_rect().get_center().x - 640.0) <= 1.0, "title quit button is centered")
	_expect(main.title_start_button.get_global_rect().end.y < main.title_quit_button.get_global_rect().position.y, "title buttons stack vertically")

	main.advance_by_pointer()
	_expect(main.current_mode == "travel", "start enters gameplay travel")
	_expect(main.opening_travel_active, "travel begins active")
	_expect(main.current_event.is_empty(), "travel has no story event")
	_expect(main.owned_memory_count() == 4, "new run grants standard memories")
	_expect(main.stage_label.text.find("100") >= 0, "travel shows 100 meter goal")
	_expect(main.operation_tray.visible, "travel shows operation tray")
	_expect(main.stage_background_clip.visible, "travel shows scrolling stage background")
	_expect(main.stage_background_tiles[0].texture != null, "travel uses stage background art")
	_expect(not main.dialogue_panel.visible, "travel hides dialogue panel")
	_expect(not main.choice_panel.visible, "travel hides choice panel")
	var scroll_before: float = main.stage_scroll_offset
	var hero_y_before: float = main.hero_box.position.y
	main._update_stage_background_scroll(0.5)
	main._update_actor_animations(0.5)
	_expect(main.stage_scroll_offset > scroll_before, "travel scroll offset advances")
	_expect(abs(main.hero_box.position.y - hero_y_before) <= 0.1, "travel hero keeps fixed foot baseline")
	main.advance_by_pointer()
	_expect(main.current_mode == "travel" and main.opening_travel_active, "travel ignores pointer skip")

	for _travel_frame in range(12):
		main._update_opening_travel(0.75)
		await process_frame
		if main.current_mode == "battle":
			break
	_expect(main.current_mode == "battle", "travel reaches battle at 100 meters")
	_expect(str(main.current_event.get("id", "")).begins_with("GAMEPLAY_BATTLE"), "battle uses gameplay event shell")
	_expect(main.battle_reward_ids.size() == 1, "battle has one gameplay reward")

	var hero_rect: Rect2 = main.hero_box.get_global_rect()
	var enemy_rect: Rect2 = main.enemy_box.get_global_rect()
	var tray_rect: Rect2 = main.operation_tray.get_global_rect()
	var stage_rect: Rect2 = main.stage_panel.get_global_rect()
	var status_rect: Rect2 = main.status_box.get_global_rect()
	var log_rect: Rect2 = main.battle_log_panel.get_global_rect()
	_expect(main.enemy_box.visible, "battle shows enemy")
	_expect(main.battle_log_panel.visible, "battle shows action log")
	_expect(hero_rect.get_center().x < enemy_rect.get_center().x, "battle hero is left of enemy")
	_expect(hero_rect.end.y <= tray_rect.position.y, "battle hero stays above tray")
	_expect(enemy_rect.end.y <= tray_rect.position.y, "battle enemy stays above tray")
	_expect(status_rect.position.x >= stage_rect.position.x and status_rect.end.x <= stage_rect.end.x, "battle status stays inside stage width")
	_expect(status_rect.position.x >= enemy_rect.end.x, "battle status stays right of enemy")
	_expect(log_rect.position.x >= stage_rect.position.x and log_rect.end.x <= stage_rect.end.x, "battle log stays inside stage width")
	_expect(log_rect.end.y <= tray_rect.position.y, "battle log stays above backpack tray")
	_expect(main.battle_active, "battle starts active")
	_expect(not main.battle_resolved, "battle starts unresolved")
	_expect(main.hero_hp == main.hero_max_hp, "battle initializes hero HP")
	_expect(main.enemy_hp == main.enemy_max_hp, "battle initializes enemy HP")
	_expect(main.battle_log_label.text.find("战斗开始") >= 0, "battle log records encounter start")
	var reward_id := str(main.battle_reward_ids[0])
	_expect(main.stage_label.text.find("HP") >= 0, "battle stage label shows HP")
	var battle_scroll_before: float = main.stage_scroll_offset
	main._update_stage_background_scroll(1.0)
	_expect(abs(main.stage_scroll_offset - battle_scroll_before) <= 0.1, "battle stops stage scrolling")
	_expect(not main.dialogue_panel.visible, "battle hides dialogue panel")

	var enemy_hp_before: int = main.enemy_hp
	for _auto_player_wait in range(20):
		main._update_battle_turn_flow(0.05)
		main._update_actor_animations(0.05)
		await process_frame
		if main.hero_attack_active:
			break
	_expect(main.hero_attack_active, "player turn triggers hero attack animation")
	_expect(main.enemy_hit_active, "player turn triggers enemy hit animation")
	_expect(main.slash_active and main.slash_effect_art.visible, "player turn shows slash effect")
	_expect(main.hit_burst_active and main.hit_burst_art.visible, "player turn shows hit burst")
	_expect(main.enemy_hp == enemy_hp_before - main.BATTLE_PLAYER_DAMAGE, "player attack reduces enemy HP")
	_expect(main.battle_log_label.text.find("你出剑") >= 0, "battle log records player attack")
	await process_frame
	_expect(main.hero_box.get_global_rect().position.x > hero_rect.position.x, "hero lunges forward")
	_expect(main.enemy_art.modulate != Color.WHITE, "enemy flashes on hit")
	_expect(main.stage_panel.get_global_rect().position != stage_rect.position, "battle impact shakes stage art")
	_expect(not main.battle_resolved, "battle remains unresolved after first hit")
	_expect(main.battle_phase == "enemy", "battle moves to enemy response phase")

	for _frame_index in range(20):
		main._update_actor_animations(0.05)
		await process_frame
		if not main._battle_animation_active():
			break
	_expect(not main._battle_animation_active(), "player attack animation completes")

	var hero_hp_before: int = main.hero_hp
	for _enemy_frame in range(20):
		main._update_battle_turn_flow(0.05)
		main._update_actor_animations(0.05)
		await process_frame
		if main.enemy_attack_active:
			break
	_expect(main.enemy_attack_active, "enemy automatically counterattacks")
	_expect(main.hero_hit_active, "enemy counterattack triggers hero hit feedback")
	_expect(main.hero_hp == hero_hp_before - main.BATTLE_ENEMY_DAMAGE, "enemy attack reduces hero HP")
	_expect(main.battle_log_label.text.find("敌人反击") >= 0, "battle log records enemy counterattack")
	for _enemy_finish_frame in range(20):
		main._update_actor_animations(0.05)
		await process_frame
		if not main._battle_animation_active():
			break
	_expect(not main._battle_animation_active(), "enemy counterattack animation completes")

	await _resolve_current_battle(main)
	_expect(main.current_mode == "travel", "resolved battle returns to travel")
	_expect(not main.battle_log_panel.visible, "battle log hides after battle")
	_expect(main.battle_log_entries.is_empty(), "battle log clears after battle")
	_expect(main.opening_travel_active, "next travel segment starts")
	_expect(main.current_event.is_empty(), "battle victory does not advance into story")
	_expect(main.has_memory(reward_id), "battle reward is added to backpack")
	_expect(main.owned_memory_count() == 5, "reward increases owned memory count")
	_expect(not main.dialogue_panel.visible and not main.choice_panel.visible and not main.ending_layer.visible, "reward flow stays gameplay-only")

	_expect(main.inventory_cells.size() == 36, "inventory shows full 9x4 grid")
	_expect(main.inventory_grid.columns == 9, "inventory uses 9 columns")
	_expect(main.unlocked_memory_slots() == 36, "inventory exposes full spatial board")
	_expect(main._screen_rect("travel", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "travel inventory board matches bag detail")
	_expect(main._screen_rect("battle", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "battle inventory board matches bag detail")
	_expect(main.trash_zone.get_global_rect().end.x <= main.inventory_grid.get_global_rect().position.x, "discard zone stays left of inventory")
	_expect(main.inventory_grid.get_global_rect().end.x <= main.found_zone.get_global_rect().position.x, "inventory stays left of found zone")

	main.open_bag_detail()
	_expect(main.current_mode == "bag_detail", "backpack detail opens from gameplay")
	main.return_to_story()
	_expect(main.current_mode == "travel", "backpack detail returns to travel")
	var sword_before: Vector2i = main._memory_grid_position("mem_wooden_sword")
	_expect(main.move_memory_to("mem_wooden_sword", Vector2i(0, 3)), "inventory rearrange can move the sword")
	_expect(main._memory_grid_position("mem_wooden_sword") != sword_before, "sword position changes after rearrange")

	main.current_mode = "memory_replace"
	main.pending_gain_memory_ids.clear()
	main.pending_gain_memory_ids.append("mem_no_more_explaining")
	main.pending_resume_event_id = "GAMEPLAY_TRAVEL"
	main._apply_mode()
	var drag_start: Vector2 = main.inventory_cells[0].get_global_rect().get_center()
	var drag_drop: Vector2 = main.trash_zone.get_global_rect().get_center()
	main._start_drag("owned", main.owned_memory_ids.find("mem_mothers_soup"), "mem_mothers_soup", drag_start)
	_expect(main.drag_active, "memory drag starts from inventory cell")
	_expect(main.drag_preview.visible, "memory drag shows preview")
	main._finish_drag(drag_drop)
	_expect(not main.drag_active, "memory drag clears after drop")
	_expect(main.current_mode == "travel", "memory replacement resumes travel")
	_expect(main.owned_memory_count() == 5, "memory replacement keeps item count after discard and gain")
	_expect(main.has_memory("mem_no_more_explaining"), "memory replacement adds pending memory")
	_expect(main.has_discarded("mem_mothers_soup"), "memory replacement discards replaced memory")
	_expect(not main.has_memory("mem_mothers_soup"), "memory replacement removes old memory")

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_reboot_shell: ok")
	quit(0)


func _resolve_current_battle(main: Control) -> void:
	for _turn_index in range(240):
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
	push_error("verify_reboot_shell: %s" % message)
