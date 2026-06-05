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
	_expect(main.loaded_event_count() >= 80, "loads MVP events from original source script")
	_expect(main.loaded_memory_count() >= 16, "loads complete memory definitions from original source script")
	_expect(main.memories.has("mem_mothers_soup"), "loads required initial memory definition")
	_expect(main.memories.has("mem_rusty_victory"), "loads late-game reward memory definition")
	_expect(main.screen_background_art.texture != null, "loads gameplay shell art")
	_expect(main.title_background_art.texture != null, "loads title background art")
	_expect(main.dialogue_panel_art.texture != null, "loads dialogue panel art")
	_expect(main.hero_art.texture != null, "loads hero transparent art")
	_expect(main.enemy_art.texture != null, "loads enemy transparent art")
	_expect(main.memory_icons_texture != null, "loads memory icon atlas")

	main.show_mode("title")
	_expect(main.title_layer.visible, "title mode shows title layer")
	_expect(not main.operation_tray.visible, "title mode hides operation tray")
	_expect(not main.dialogue_panel.visible, "title mode hides dialogue panel")
	_expect(abs(main.title_start_button.get_global_rect().get_center().x - 640.0) <= 1.0, "title start button is centered on screen")
	_expect(abs(main.title_quit_button.get_global_rect().get_center().x - 640.0) <= 1.0, "title quit button is centered on screen")
	_expect(main.title_start_button.get_global_rect().end.y < main.title_quit_button.get_global_rect().position.y, "title buttons stack vertically")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "T0001", "mouse pointer advance starts script from title")

	main.jump_to_event("T0001")
	_expect(main.dialogue_panel.visible, "dialogue event shows dialogue panel")
	_expect(not main.operation_tray.visible, "dialogue event hides operation tray")
	_expect(main.text_label.text.find("自动前进") >= 0, "dialogue text comes from original script")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "T0002", "mouse pointer advance progresses dialogue")

	main.jump_to_event("P0010")
	_expect(main.operation_tray.visible, "memory event shows operation tray")
	_expect(not main.dialogue_panel.visible, "memory event hides dialogue panel")

	main.jump_to_event("F0010")
	_expect(main.current_mode == "choice", "choice event switches to choice mode")
	_expect(not main.dialogue_panel.visible, "choice mode hides dialogue panel to avoid backpack overlap")
	_expect(main.choice_panel.visible, "choice mode shows choice panel")
	_expect(main.available_choice_options.size() == 3, "choice mode filters and shows available options")

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
	_expect(status_rect.position.x >= stage_rect.position.x and status_rect.end.x <= stage_rect.end.x, "battle status should stay inside stage width")
	_expect(status_rect.position.x >= enemy_rect.end.x, "battle status should stay right of enemy placeholder")
	_expect(main.battle_active, "battle starts active")
	_expect(not main.battle_resolved, "battle starts unresolved")
	main.advance_by_pointer()
	_expect(main.hero_attack_active, "battle advance triggers hero attack animation")
	_expect(main.enemy_hit_active, "battle advance triggers enemy hit animation")
	_expect(main.slash_active and main.slash_effect_art.visible, "battle advance shows slash effect")
	_expect(main.hit_burst_active and main.hit_burst_art.visible, "battle advance shows hit burst effect")
	await process_frame
	_expect(main.hero_box.get_global_rect().position.x > hero_rect.position.x, "hero lunges forward during attack animation")
	_expect(main.enemy_art.modulate != Color.WHITE, "enemy flashes during hit animation")
	_expect(main.stage_panel.get_global_rect().position != stage_rect.position, "battle impact shakes stage art")
	_expect(main.battle_resolved, "battle resolves after advance")
	_expect(main.status_box_label.text.find("胜利") >= 0, "battle status shows victory")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "F0003", "battle ignores progress while attack animation is still playing")
	for _frame_index in range(20):
		main._update_actor_animations(0.05)
		await process_frame
		if not main._battle_animation_active():
			break
	_expect(not main._battle_animation_active(), "battle attack animation completes")
	main.advance_by_pointer()
	_expect(str(main.current_event.get("id", "")) == "F0004", "resolved battle advances to next script event")

	_expect(main.inventory_cells.size() == 36, "inventory shows full 9x4 grid")
	_expect(main.inventory_grid.columns == 9, "inventory uses 9 columns")
	_expect(main.unlocked_memory_slots() == 36, "inventory exposes the full 9x4 spatial board")
	_expect(main._screen_rect("travel", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "travel inventory board matches painted backpack grid")
	_expect(main._screen_rect("battle", "inventory_board") == main._screen_rect("bag_detail", "inventory_board"), "battle inventory board matches painted backpack grid")
	_expect(main.trash_zone.get_global_rect().end.x <= main.inventory_grid.get_global_rect().position.x, "discard zone stays left of backpack grid")
	_expect(main.inventory_grid.get_global_rect().end.x <= main.found_zone.get_global_rect().position.x, "backpack grid stays left of found-memory zone")
	main.open_bag_detail()
	_expect(main.current_mode == "bag_detail", "mouse-accessible backpack detail opens from story")
	main.return_to_story()
	_expect(main.current_mode == "dialogue", "backpack detail returns to previous story mode")

	main.start_script()
	_expect(str(main.current_event.get("id", "")) == "T0001", "start_script begins at first tutorial event")
	for _index in range(38):
		if str(main.current_event.get("id", "")) == "P0034":
			break
		main.advance_script()
	_expect(str(main.current_event.get("id", "")) == "P0034", "script playback reaches initial backpack choice")
	_expect(main.current_mode == "choice", "initial backpack event is a choice")
	_expect(main.available_choice_options.size() == 2, "initial backpack choice exposes two valid options")
	main.choose_option(0)
	_expect(str(main.current_event.get("id", "")) == "P0035A", "choice target jumps to standard opening line")
	_expect(main.owned_memory_count() == 4, "standard opening gains four memories")
	_expect(main.has_memory("mem_mothers_soup"), "standard opening keeps mother's soup")
	_expect(main.has_memory("mem_my_name"), "standard opening keeps hero name")
	_expect(main._memory_grid_size("mem_wooden_sword") == Vector2i(4, 1), "wooden sword occupies four horizontal cells")
	_expect(main._memory_grid_size("mem_reason_to_depart") == Vector2i(2, 3), "reason journal occupies a 2x3 block")
	_expect(main.inventory_item_layer.get_child_count() == 4, "owned memories render as placed multi-cell items")
	var sword_before: Vector2i = main._memory_grid_position("mem_wooden_sword")
	_expect(main.move_memory_to("mem_wooden_sword", Vector2i(0, 3)), "mouse-style inventory rearrange can move the sword")
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
	var drag_start: Vector2 = main.inventory_cells[main._memory_grid_position("mem_mothers_soup").x].get_global_rect().get_center()
	var drag_drop: Vector2 = main.trash_zone.get_global_rect().get_center()
	main._start_drag("owned", main.owned_memory_ids.find("mem_mothers_soup"), "mem_mothers_soup", drag_start)
	_expect(main.drag_active, "memory drag starts from inventory cell")
	_expect(main.drag_preview.visible, "memory drag shows preview")
	main._finish_drag(drag_drop)
	_expect(not main.drag_active, "memory drag clears after drop")
	_expect(str(main.current_event.get("id", "")) == "F0011A", "memory replacement resumes selected branch")
	_expect(main.owned_memory_count() == 5, "memory replacement keeps current item count after one discard and one gain")
	_expect(main.has_memory("mem_no_more_explaining"), "memory replacement adds pending memory")
	_expect(main.has_discarded("mem_mothers_soup"), "memory replacement discards replaced memory")
	_expect(not main.has_memory("mem_mothers_soup"), "memory replacement removes old memory from bag")

	main.show_mode("bag_detail")
	_expect(main.bag_detail_layer.visible, "bag detail mode shows detail layer")
	_expect(main.bag_memory_list.get_global_rect().end.x < main.bag_detail_panel.get_global_rect().position.x, "bag list should be left of detail panel")
	_expect(main.bag_detail_panel.get_global_rect().end.y < main.bag_detail_inventory.get_global_rect().position.y, "bag detail should be above the full inventory board")
	_expect(main.bag_detail_layer.get_node("BagDetailClose").get_global_rect().end.y + 72.0 <= main.bag_detail_inventory.get_global_rect().position.y, "bag detail inventory should stay visually separated from close button")
	_expect(main.bag_detail_inventory.get_global_rect().end.y <= 720.0, "bag detail inventory should stay within detail screen height")
	_expect(main.bag_detail_cells.size() == 36, "bag detail should reuse full 9x4 grid")

	main.show_mode("ending")
	_expect(main.ending_layer.visible, "ending mode shows ending layer")
	_expect(main.ending_summary_panel.get_global_rect().end.x < main.ending_memory_panel.get_global_rect().position.x, "ending summary should be left of memory panel")
	_expect(not main.operation_tray.visible, "ending mode hides operation tray")
	main.start_script()
	main.show_mode("ending")
	main._on_ending_title_gui_input(_mouse_click())
	_expect(main.current_mode == "title", "ending title button returns to title")
	main.show_mode("ending")
	main._on_ending_restart_gui_input(_mouse_click())
	_expect(str(main.current_event.get("id", "")) == "T0001", "ending restart button starts a new script run")

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
