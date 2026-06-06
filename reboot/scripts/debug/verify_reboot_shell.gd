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
	_expect(main.current_mode == "prologue", "start enters prologue")
	_expect(main.prologue_dialogue_art.visible, "prologue shows dialogue art")
	_expect(not main.dialogue_panel.visible, "prologue hides legacy dialogue panel")
	_expect(not main.operation_tray.visible, "prologue hides operation tray")
	_expect(main.prologue_speaker_label.text == "旁白", "prologue uses narrator")
	_expect(main.prologue_text_label.text == str(main.PROLOGUE_LINES[0]), "prologue shows first line")
	main.advance_by_pointer()
	_expect(main.current_mode == "prologue", "prologue advances one line")
	_expect(main.prologue_line_index == 1, "prologue line index advances")
	await _finish_prologue(main)
	_expect(main.current_mode == "travel", "prologue ends into gameplay travel")
	_expect(main.opening_travel_active, "travel begins active")
	_expect(main.current_event.is_empty(), "travel has no story event")
	_expect(main.owned_memory_count() == 4, "new run grants standard memories")
	_expect(main.stage_label.text.find("100") >= 0, "travel shows 100 meter goal")
	_expect(main.operation_tray.visible, "travel shows operation tray")
	_expect(main.stage_background_clip.visible, "travel shows scrolling stage background")
	_expect(main.stage_background_tiles[0].texture != null, "travel uses stage background art")
	_expect(main.prev_map_button.visible and main.next_map_button.visible, "travel shows map switch buttons")
	_expect(main.prev_map_button.get_global_rect().end.x < main.next_map_button.get_global_rect().position.x, "map switch buttons are ordered")
	var initial_map_index: int = main.current_stage_map_index
	main.cycle_stage_map(1)
	_expect(main.current_stage_map_index == (initial_map_index + 1) % main.stage_background_textures.size(), "next map button cycles stage map")
	_expect(main.stage_background_tiles[0].texture == main.stage_background_textures[main.current_stage_map_index], "stage tile texture updates after next map")
	main.cycle_stage_map(-1)
	_expect(main.current_stage_map_index == initial_map_index, "previous map button cycles back")
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
	_expect(not main.prev_map_button.visible and not main.next_map_button.visible, "battle hides map switch buttons")

	var hero_rect: Rect2 = main.hero_box.get_global_rect()
	var enemy_rect: Rect2 = main.enemy_box.get_global_rect()
	var tray_rect: Rect2 = main.operation_tray.get_global_rect()
	var stage_rect: Rect2 = main.stage_panel.get_global_rect()
	var status_rect: Rect2 = main.status_box.get_global_rect()
	var log_rect: Rect2 = main.battle_log_panel.get_global_rect()
	var inventory_rect: Rect2 = main.inventory_grid.get_global_rect()
	_expect(main.enemy_box.visible, "battle shows enemy")
	_expect(main.battle_log_panel.visible, "battle shows action log")
	_expect(inventory_rect == tray_rect, "battle inventory fills tray")
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
	main._stop_battle_attack_animation()
	main.battle_resolved = false
	main.battle_active = true
	main.battle_phase = "player"
	main.enemy_hp = main.enemy_max_hp
	main.normal_attack_counter = main.SKILL_TRIGGER_NORMAL_ATTACKS
	var skill_enemy_hp_before: int = main.enemy_hp
	main._perform_player_battle_turn()
	_expect(main.current_attack_is_skill, "third player attack triggers a skill")
	_expect(not main.current_skill.is_empty(), "skill attack records current skill")
	var skill_id := str(main.current_skill.get("id", ""))
	_expect(main._skill_cooldown_remaining(skill_id) > 1.8, "used skill enters cooldown")
	_expect(main.skill_banner_label.visible, "skill attack shows skill name banner")
	_expect(main.skill_banner_label.text == str(main.current_skill.get("name", "")), "skill banner shows current skill name")
	_expect(main.slash_active and main.current_slash_frames.size() == 6, "skill attack uses skill slash frames")
	_expect(main.current_slash_frames[0] != main.slash_effect_frames[0], "skill slash differs from normal slash")
	_expect(main.enemy_hp <= skill_enemy_hp_before - main.BATTLE_PLAYER_DAMAGE, "skill attack deals at least normal damage")
	_expect(main.battle_log_label.text.find(str(main.current_skill.get("name", ""))) >= 0, "battle log records skill name")
	main._update_skill_cooldowns(main.SKILL_COOLDOWN_SECONDS)
	_expect(main._skill_cooldown_remaining(skill_id) <= 0.0, "skill cooldown expires after two seconds")

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
	_expect(not main.has_memory(reward_id), "first battle does not immediately add reward")
	_expect(main.owned_memory_count() == 4, "first battle only grants experience")
	_expect(main.battle_experience == 1 and main.player_level == 1, "first battle increases experience")
	_expect(main.last_reward_notice.find("经验") >= 0, "travel label has experience reward notice")
	_expect(not main.dialogue_panel.visible and not main.choice_panel.visible and not main.ending_layer.visible, "reward flow stays gameplay-only")
	main.battle_experience = main.BATTLES_PER_LEVEL - 1
	var reward_count_before: int = main.owned_memory_count()
	var level_rewards: Array[String] = main._battle_level_reward_ids()
	_expect(main.player_level == 2 and main.battle_experience == 0, "third battle levels up")
	_expect(level_rewards.size() == 1, "level up rolls one random item")
	main._add_memories(level_rewards)
	_expect(main.owned_memory_count() == reward_count_before + 1, "level reward adds one memory")

	_expect(main.inventory_cells.size() == 36, "inventory shows full 9x4 grid")
	_expect(main.inventory_grid.columns == 9, "inventory uses 9 columns")
	_expect(main.unlocked_memory_slots() == 36, "inventory exposes full spatial board")
	_expect(main._screen_rect("travel", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "travel inventory board matches bag detail")
	_expect(main._screen_rect("battle", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "battle inventory board matches bag detail")
	_expect(main.inventory_grid.get_global_rect() == main.operation_tray.get_global_rect(), "inventory fills the whole bottom tray")

	main.open_bag_detail()
	_expect(main.current_mode == "bag_detail", "backpack detail opens from gameplay")
	main.return_to_story()
	_expect(main.current_mode == "travel", "backpack detail returns to travel")
	var sword_before: Vector2i = main._memory_grid_position("mem_wooden_sword")
	var sword_move_position := _find_placeable_position(main, "mem_wooden_sword", "mem_wooden_sword", sword_before)
	_expect(sword_move_position.x >= 0, "test can find an open sword target")
	_expect(main.move_memory_to("mem_wooden_sword", sword_move_position), "inventory rearrange can move the sword")
	_expect(main._memory_grid_position("mem_wooden_sword") != sword_before, "sword position changes after rearrange")
	var sword_pointer: Vector2 = _memory_pointer(main, "mem_wooden_sword")
	main._update_memory_tooltip(sword_pointer)
	_expect(main.memory_tooltip_panel.visible, "hovering memory shows tooltip")
	_expect(main.memory_tooltip_label.text.find("木剑") >= 0, "memory tooltip includes item name")
	main._start_drag("owned", main.owned_memory_ids.find("mem_wooden_sword"), "mem_wooden_sword", sword_pointer)
	_expect(main.drag_active, "owned memory drag starts")
	_expect(main.drag_preview.visible, "owned memory drag shows preview")
	_expect(main.drag_preview.get_global_rect().has_point(sword_pointer), "drag preview keeps pointer over item")
	var follow_pointer := sword_pointer + Vector2(38, 24)
	main._update_drag_preview_position(follow_pointer)
	_expect(main.drag_preview.position.distance_to(follow_pointer - main.drag_preview_pointer_offset) <= 0.1, "drag preview preserves grab offset")
	_expect(not main.memory_tooltip_panel.visible, "drag hides memory tooltip")
	var target_position := _find_placeable_position(main, "mem_wooden_sword", "mem_wooden_sword", main._memory_grid_position("mem_wooden_sword"))
	_expect(target_position.x >= 0, "test can find drag hover target")
	var target_pointer: Vector2 = _grid_pointer(main, target_position)
	main._update_drag_hover(target_pointer)
	_expect(main.drag_hover_grid_position == target_position, "drag hover follows target cell")
	var target_slot: int = target_position.y * main.inventory_grid_size().x + target_position.x
	_expect(main.inventory_cells[target_slot].modulate != Color(1, 1, 1, 1), "drag target cells are highlighted")
	_expect(main.inventory_cells[target_slot].scale.x > 1.0, "drag target cells lift outward")
	main._finish_drag(target_pointer)
	_expect(not main.drag_active, "owned memory drag clears after drop")

	main.current_mode = "memory_replace"
	main.pending_gain_memory_ids.clear()
	var pending_test_id := "mem_no_more_explaining"
	if main.has_memory(pending_test_id):
		pending_test_id = "mem_empty_nameplate"
	main.pending_gain_memory_ids.append(pending_test_id)
	var pending_count_before: int = main.owned_memory_count()
	main.pending_resume_event_id = "GAMEPLAY_TRAVEL"
	main._apply_mode()
	var pending_position: Vector2i = main._first_available_position(pending_test_id)
	_expect(pending_position.x >= 0, "test can find pending item placement")
	var drag_start: Vector2 = _grid_pointer(main, pending_position)
	var drag_drop: Vector2 = _grid_pointer(main, pending_position)
	main._start_drag("pending", -1, pending_test_id, drag_start)
	_expect(main.drag_active, "memory drag starts from inventory cell")
	_expect(main.drag_preview.visible, "memory drag shows preview")
	main._finish_drag(drag_drop)
	_expect(not main.drag_active, "memory drag clears after drop")
	_expect(main.current_mode == "travel", "memory replacement resumes travel")
	_expect(main.owned_memory_count() == pending_count_before + 1, "memory replacement adds pending item without discard")
	_expect(main.has_memory(pending_test_id), "memory replacement adds pending memory")
	_expect(main.has_memory("mem_mothers_soup"), "memory replacement keeps existing memory")

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


func _finish_prologue(main: Control) -> void:
	for _line_index in range(main.PROLOGUE_LINES.size() + 2):
		if main.current_mode != "prologue":
			return
		main.advance_by_pointer()
		await process_frame


func _find_placeable_position(main: Control, memory_id: String, ignore_memory_id := "", excluded_position := Vector2i(-1, -1)) -> Vector2i:
	var grid_size: Vector2i = main.inventory_grid_size()
	var item_size: Vector2i = main._memory_grid_size(memory_id)
	for y in range(0, grid_size.y - item_size.y + 1):
		for x in range(0, grid_size.x - item_size.x + 1):
			var candidate := Vector2i(x, y)
			if candidate == excluded_position:
				continue
			if main._can_place_memory(memory_id, candidate, ignore_memory_id):
				return candidate
	return Vector2i(-1, -1)


func _grid_pointer(main: Control, grid_position: Vector2i) -> Vector2:
	var slot: int = grid_position.y * main.inventory_grid_size().x + grid_position.x
	if slot < 0 or slot >= main.inventory_cells.size():
		return Vector2.ZERO
	return main.inventory_cells[slot].get_global_rect().get_center()


func _memory_pointer(main: Control, memory_id: String) -> Vector2:
	var position: Vector2i = main._memory_grid_position(memory_id)
	var size: Vector2i = main._memory_grid_size(memory_id)
	return _grid_pointer(main, position + Vector2i(size.x / 2, size.y / 2))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_reboot_shell: %s" % message)
