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
	_expect(main.loaded_memory_count() == 8, "loads exactly 8 MVP memories")

	main.show_mode("title")
	_expect(main.title_layer.visible, "title mode shows title layer")
	_expect(not main.operation_tray.visible, "title mode hides operation tray")
	_expect(not main.dialogue_panel.visible, "title mode hides dialogue panel")
	_expect(main.title_text_label.get_global_rect().position.x < main.title_concept_preview.get_global_rect().position.x, "title text should stay left of concept preview")

	main.jump_to_event("T0001")
	_expect(main.dialogue_panel.visible, "dialogue event shows dialogue panel")
	_expect(not main.operation_tray.visible, "dialogue event hides operation tray")
	_expect(main.text_label.text.find("自动前进") >= 0, "dialogue text comes from original script")

	main.jump_to_event("P0010")
	_expect(main.operation_tray.visible, "memory event shows operation tray")
	_expect(not main.dialogue_panel.visible, "memory event hides dialogue panel")

	main.jump_to_event("F0010")
	_expect(main.current_mode == "choice", "choice event switches to choice mode")
	_expect(main.dialogue_panel.visible, "choice mode keeps story text visible")
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
	_expect(status_rect.end.y < enemy_rect.position.y, "battle status should stay above enemy placeholder")

	_expect(main.inventory_cells.size() == 28, "inventory shows full 7x4 grid")
	_expect(main.inventory_grid.columns == 7, "inventory uses 7 columns")

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

	main.jump_to_event("F0010")
	main.choose_option(0)
	_expect(main.current_mode == "memory_replace", "full backpack gain opens memory replacement")
	_expect(main.pending_gain_memory_ids.size() == 1, "memory replacement tracks pending gain")
	_expect(main.pending_gain_memory_ids[0] == "mem_someone_waits", "memory replacement stores selected new memory")
	main.replace_memory_at(0)
	_expect(str(main.current_event.get("id", "")) == "F0011A", "memory replacement resumes selected branch")
	_expect(main.owned_memory_count() == 4, "memory replacement keeps unlocked capacity")
	_expect(main.has_memory("mem_someone_waits"), "memory replacement adds new memory")
	_expect(main.has_discarded("mem_mothers_soup"), "memory replacement discards replaced memory")
	_expect(not main.has_memory("mem_mothers_soup"), "memory replacement removes old memory from bag")

	main.show_mode("bag_detail")
	_expect(main.bag_detail_layer.visible, "bag detail mode shows detail layer")
	_expect(main.bag_memory_list.get_global_rect().end.x < main.bag_detail_panel.get_global_rect().position.x, "bag list should be left of detail panel")
	_expect(main.bag_detail_panel.get_global_rect().end.x < main.bag_detail_inventory.get_global_rect().position.x, "bag detail should be left of inventory board")
	_expect(main.bag_detail_layer.get_node("BagDetailClose").get_global_rect().end.y + 72.0 <= main.bag_detail_inventory.get_global_rect().position.y, "bag detail inventory should stay visually separated from close button")
	_expect(main.bag_detail_inventory.get_global_rect().end.y <= main.bag_detail_panel.get_global_rect().end.y, "bag detail inventory should stay within detail screen height")
	_expect(main.bag_detail_cells.size() == 28, "bag detail should reuse full 7x4 grid")

	main.show_mode("ending")
	_expect(main.ending_layer.visible, "ending mode shows ending layer")
	_expect(main.ending_summary_panel.get_global_rect().end.x < main.ending_memory_panel.get_global_rect().position.x, "ending summary should be left of memory panel")
	_expect(not main.operation_tray.visible, "ending mode hides operation tray")

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
