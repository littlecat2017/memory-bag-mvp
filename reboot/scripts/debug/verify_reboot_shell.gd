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
	_expect(main.loaded_event_count() >= 80, "loads MVP events from source script")
	_expect(main.loaded_memory_count() >= 16, "loads memory definitions from source script")
	_expect(main.memories.has("mem_mothers_soup"), "loads required initial memory")
	_expect(main.memories.has("mem_rusty_victory"), "loads late-game reward memory")
	_expect(main.screen_background_art.texture != null, "loads gameplay shell art")
	_expect(main.title_background_art.texture != null, "loads title background art")
	_expect(main.dialogue_panel_art.texture != null, "loads dialogue panel art")
	_expect(main.hero_art.texture != null, "loads hero art")
	_expect(main.enemy_art.texture != null, "loads enemy art")
	_expect(main.memory_icons_texture != null, "loads memory icon atlas")

	main.show_mode("title")
	_expect(main.title_layer.visible, "title mode shows title layer")
	_expect(not main.operation_tray.visible, "title mode hides operation tray")
	_expect(not main.dialogue_panel.visible, "title mode hides dialogue panel")
	_expect(abs(main.title_start_button.get_global_rect().get_center().x - 640.0) <= 1.0, "title start button is centered")
	_expect(abs(main.title_quit_button.get_global_rect().get_center().x - 640.0) <= 1.0, "title quit button is centered")
	_expect(main.title_start_button.get_global_rect().end.y < main.title_quit_button.get_global_rect().position.y, "title buttons stack vertically")
	main.advance_by_pointer()
	_expect(main.current_mode == "travel", "start button enters streamlined travel opening")
	_expect(main.opening_travel_active, "streamlined opening begins with walking")
	_expect(main.owned_memory_count() == 4, "streamlined opening grants standard memories")
	_expect(main.stage_label.text.find("100") >= 0, "streamlined opening shows 100 meter goal")
	main.advance_by_pointer()
	_expect(main.current_mode == "travel" and main.opening_travel_active, "opening travel ignores pointer skip")
	for _travel_frame in range(8):
		main._update_opening_travel(0.75)
		await process_frame
		if str(main.current_event.get("id", "")) == "F0003":
			break
	_expect(str(main.current_event.get("id", "")) == "F0003", "opening travel reaches first battle at 100 meters")

	main.jump_to_event("T0001")
	_expect(main.dialogue_panel.visible, "dialogue event shows dialogue panel")
	_expect(not main.operation_tray.visible, "dialogue event hides operation tray")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "T0002", "pointer advances dialogue")

	main.jump_to_event("P0010")
	_expect(main.operation_tray.visible, "memory event shows operation tray")
	_expect(not main.dialogue_panel.visible, "memory event hides dialogue panel")

	main.jump_to_event("F0010")
	_expect(main.current_mode == "choice", "choice event switches to choice mode")
	_expect(not main.dialogue_panel.visible, "choice mode hides dialogue panel")
	_expect(main.choice_panel.visible, "choice mode shows choice panel")
	_expect(main.available_choice_options.size() == 3, "choice mode shows available options")

	main.jump_to_event("F0003")
	var hero_rect: Rect2 = main.hero_box.get_global_rect()
	var enemy_rect: Rect2 = main.enemy_box.get_global_rect()
	var tray_rect: Rect2 = main.operation_tray.get_global_rect()
	var stage_rect: Rect2 = main.stage_panel.get_global_rect()
	var status_rect: Rect2 = main.status_box.get_global_rect()
	_expect(main.enemy_box.visible, "battle event shows enemy")
	_expect(hero_rect.get_center().x < enemy_rect.get_center().x, "battle hero is left of enemy")
	_expect(hero_rect.end.y <= tray_rect.position.y, "battle hero stays above tray")
	_expect(enemy_rect.end.y <= tray_rect.position.y, "battle enemy stays above tray")
	_expect(status_rect.position.x >= stage_rect.position.x and status_rect.end.x <= stage_rect.end.x, "battle status stays inside stage width")
	_expect(status_rect.position.x >= enemy_rect.end.x, "battle status stays right of enemy")
	_expect(main.battle_active, "battle starts active")
	_expect(not main.battle_resolved, "battle starts unresolved")
	_expect(main.hero_hp == main.hero_max_hp, "battle initializes hero HP")
	_expect(main.enemy_hp == main.enemy_max_hp, "battle initializes enemy HP")
	_expect(main.stage_label.text.find("HP") >= 0, "battle stage label shows HP")

	var enemy_hp_before: int = main.enemy_hp
	main.advance_by_pointer()
	_expect(main.hero_attack_active, "player turn triggers hero attack animation")
	_expect(main.enemy_hit_active, "player turn triggers enemy hit animation")
	_expect(main.slash_active and main.slash_effect_art.visible, "player turn shows slash effect")
	_expect(main.hit_burst_active and main.hit_burst_art.visible, "player turn shows hit burst")
	_expect(main.enemy_hp == enemy_hp_before - main.BATTLE_PLAYER_DAMAGE, "player attack reduces enemy HP")
	await process_frame
	_expect(main.hero_box.get_global_rect().position.x > hero_rect.position.x, "hero lunges forward")
	_expect(main.enemy_art.modulate != Color.WHITE, "enemy flashes on hit")
	_expect(main.stage_panel.get_global_rect().position != stage_rect.position, "battle impact shakes stage art")
	_expect(not main.battle_resolved, "battle remains unresolved after first hit")
	_expect(main.battle_phase == "enemy", "battle moves to enemy response phase")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "F0003", "battle ignores progress while attack animation plays")
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
	for _enemy_finish_frame in range(20):
		main._update_actor_animations(0.05)
		await process_frame
		if not main._battle_animation_active():
			break
	_expect(not main._battle_animation_active(), "enemy counterattack animation completes")

	for _turn_index in range(8):
		if main.battle_resolved:
			break
		main.advance_by_pointer()
		for _finish_frame in range(24):
			main._update_actor_animations(0.05)
			await process_frame
			if not main._battle_animation_active():
				break
		if not main.battle_resolved:
			for _response_frame in range(24):
				main._update_battle_turn_flow(0.05)
				main._update_actor_animations(0.05)
				await process_frame
				if not main._battle_animation_active() and main.battle_phase == "player":
					break
	_expect(main.battle_resolved, "battle resolves after enough player turns")
	_expect(main.status_box_label.text.find("胜利") >= 0 or main.status_box_label.text.find("HP") >= 0, "battle status reaches victory state")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "F0004", "resolved battle advances to next script event")

	_expect(main.inventory_cells.size() == 36, "inventory shows full 9x4 grid")
	_expect(main.inventory_grid.columns == 9, "inventory uses 9 columns")
	_expect(main.unlocked_memory_slots() == 36, "inventory exposes full spatial board")
	_expect(main._screen_rect("travel", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "travel inventory board matches bag detail")
	_expect(main._screen_rect("battle", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "battle inventory board matches bag detail")
	_expect(main.trash_zone.get_global_rect().end.x <= main.inventory_grid.get_global_rect().position.x, "discard zone stays left of inventory")
	_expect(main.inventory_grid.get_global_rect().end.x <= main.found_zone.get_global_rect().position.x, "inventory stays left of found zone")
	main.open_bag_detail()
	_expect(main.current_mode == "bag_detail", "backpack detail opens from story")
	main.return_to_story()
	_expect(main.current_mode == "dialogue", "backpack detail returns to previous story mode")

	main.start_source_script()
	_expect(str(main.current_event.get("id", "")) == "T0001", "source script helper begins at tutorial event")
	for _index in range(38):
		if str(main.current_event.get("id", "")) == "P0034":
			break
		main.advance_script()
	_expect(str(main.current_event.get("id", "")) == "P0034", "source script reaches initial backpack choice")
	_expect(main.current_mode == "choice", "initial backpack event is a choice")
	_expect(main.available_choice_options.size() == 2, "initial backpack choice exposes two valid options")
	main.choose_option(0)
	_expect(str(main.current_event.get("id", "")) == "P0035A", "choice target jumps to standard opening line")
	_expect(main.owned_memory_count() == 4, "standard opening gains four memories")
	_expect(main.has_memory("mem_mothers_soup"), "standard opening keeps mother's soup")
	_expect(main.has_memory("mem_my_name"), "standard opening keeps hero name")
	_expect(main._memory_grid_size("mem_wooden_sword") == Vector2i(4, 1), "wooden sword occupies four horizontal cells")
	_expect(main._memory_grid_size("mem_reason_to_depart") == Vector2i(2, 3), "reason journal occupies a 2x3 block")
	main.show_mode("travel")
	await process_frame
	_expect(main.inventory_item_layer.get_child_count() == 4, "owned memories render as placed items")
	var sword_before: Vector2i = main._memory_grid_position("mem_wooden_sword")
	_expect(main.move_memory_to("mem_wooden_sword", Vector2i(0, 3)), "inventory rearrange can move the sword")
	_expect(main._memory_grid_position("mem_wooden_sword") != sword_before, "sword position changes after rearrange")

	main.jump_to_event("F0010")
	main.choose_option(0)
	_expect(main.current_mode == "dialogue", "spatial backpack accepts a new memory when there is room")
	_expect(main.has_memory("mem_someone_waits"), "spatial backpack places newly gained memory")
	_expect(main._memory_grid_position("mem_someone_waits").x >= 0, "new memory receives a grid position")

	main.current_mode = "memory_replace"
	main.pending_gain_memory_ids.clear()
	main.pending_gain_memory_ids.append("mem_no_more_explaining")
	main.pending_resume_event_id = "F0011A"
	var drag_start: Vector2 = main.inventory_cells[0].get_global_rect().get_center()
	var drag_drop: Vector2 = main.trash_zone.get_global_rect().get_center()
	main._start_drag("owned", main.owned_memory_ids.find("mem_mothers_soup"), "mem_mothers_soup", drag_start)
	_expect(main.drag_active, "memory drag starts from inventory cell")
	_expect(main.drag_preview.visible, "memory drag shows preview")
	main._finish_drag(drag_drop)
	_expect(not main.drag_active, "memory drag clears after drop")
	_expect(str(main.current_event.get("id", "")) == "F0011A", "memory replacement resumes selected branch")
	_expect(main.owned_memory_count() == 5, "memory replacement keeps item count after discard and gain")
	_expect(main.has_memory("mem_no_more_explaining"), "memory replacement adds pending memory")
	_expect(main.has_discarded("mem_mothers_soup"), "memory replacement discards replaced memory")
	_expect(not main.has_memory("mem_mothers_soup"), "memory replacement removes old memory")

	main.show_mode("bag_detail")
	_expect(main.bag_detail_layer.visible, "bag detail mode shows detail layer")
	_expect(main.bag_memory_list.get_global_rect().end.x < main.bag_detail_panel.get_global_rect().position.x, "bag list stays left of detail panel")
	_expect(main.bag_detail_panel.get_global_rect().end.y < main.bag_detail_inventory.get_global_rect().position.y, "bag detail stays above inventory")
	_expect(main.bag_detail_layer.get_node("BagDetailClose").get_global_rect().end.y + 72.0 <= main.bag_detail_inventory.get_global_rect().position.y, "bag detail inventory stays separated from close button")
	_expect(main.bag_detail_inventory.get_global_rect().end.y <= 720.0, "bag detail inventory stays within screen")
	_expect(main.bag_detail_cells.size() == 36, "bag detail reuses full grid")

	main.show_mode("ending")
	_expect(main.ending_layer.visible, "ending mode shows ending layer")
	_expect(main.ending_summary_panel.get_global_rect().end.x < main.ending_memory_panel.get_global_rect().position.x, "ending summary stays left of memory panel")
	_expect(not main.operation_tray.visible, "ending mode hides operation tray")
	main.start_script()
	main.show_mode("ending")
	main._on_ending_title_gui_input(_mouse_click())
	_expect(main.current_mode == "title", "ending title button returns to title")
	main.show_mode("ending")
	main._on_ending_restart_gui_input(_mouse_click())
	_expect(main.current_mode == "travel" and main.opening_travel_active, "ending restart starts streamlined opening")

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_reboot_shell: ok")
	quit(0)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_reboot_shell: %s" % message)


func _mouse_click() -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	return event
