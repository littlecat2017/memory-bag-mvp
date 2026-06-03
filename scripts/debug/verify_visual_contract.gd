extends SceneTree

const MainScene := preload("res://scenes/main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.size = Vector2(1280, 720)
	await _settle(8)

	_verify_layout_data(main)
	_verify_inventory_contract(main)
	_verify_dialogue_contract(main)
	main.run_controller.pause()
	main.debug_jump_to_event("F0003")
	await _wait_for_battle_identity(main)
	_verify_battle_contract(main)

	main.queue_free()
	await process_frame
	print("verify_visual_contract: ok")
	quit(0)


func _verify_layout_data(main: Control) -> void:
	var canvas = main.registry.visual_layout.get("design_canvas", [])
	_expect(typeof(canvas) == TYPE_ARRAY and canvas.size() == 2, "visual layout must define design canvas")
	_expect(int(canvas[0]) == 1280 and int(canvas[1]) == 720, "visual layout must use 1280x720 design canvas")
	_expect(main._layout_grid_size() == Vector2i(7, 4), "visual layout must define 7x4 inventory grid")
	_expect(main._layout_unlocked_slots() == 4, "MVP should unlock exactly four initial slots")
	_expect(bool(main.registry.visual_layout.get("rules", {}).get("locked_slots_visible", false)), "locked slots must remain visible")


func _verify_inventory_contract(main: Control) -> void:
	main._show_backpack_ui()
	await _settle(2)
	_expect(main.quick_bag_slots.size() == 28, "runtime inventory must instantiate 28 concept-grid cells")
	var locked_count := 0
	for slot in main.quick_bag_slots:
		if slot.target_kind == "locked":
			locked_count += 1
			_expect(slot.visible, "locked inventory slot should be visible")
			_expect(slot.backing_texture_rect.texture != null, "locked inventory slot should have texture backing")
	_expect(locked_count == 24, "MVP should show 24 locked cells in a 7x4 grid")
	_expect(main.quick_bag_slots[0].get_global_rect().position.x < main.quick_bag_slots[6].get_global_rect().position.x, "inventory grid first row should progress left to right")
	_expect(main.quick_bag_slots[0].get_global_rect().position.y < main.quick_bag_slots[21].get_global_rect().position.y, "inventory grid should have multiple visible rows")


func _verify_dialogue_contract(main: Control) -> void:
	main.run_controller.pause()
	main._show_dialogue_ui()
	_expect(main.dialogue_panel.visible, "dialogue mode should show dialogue panel")
	_expect(not main.quick_bag_bar.visible, "dialogue mode should hide inventory tray")
	main._show_backpack_ui()
	_expect(main.quick_bag_bar.visible, "backpack mode should show inventory tray")
	_expect(not main.dialogue_panel.visible, "backpack mode should hide dialogue panel")


func _verify_battle_contract(main: Control) -> void:
	var hero_rect: Rect2 = main.battle_chibi_hero_texture_rect.get_global_rect()
	var enemy_rect: Rect2 = main.battle_chibi_enemy_texture_rect.get_global_rect()
	var tray_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	_expect(hero_rect.get_center().x < enemy_rect.get_center().x, "battle hero must be left of enemy")
	_expect(abs(hero_rect.end.y - enemy_rect.end.y) < 30.0, "battle hero and enemy should share a close ground baseline")
	_expect(hero_rect.end.y < tray_rect.position.y, "battle hero must stay above inventory tray")
	_expect(enemy_rect.end.y < tray_rect.position.y, "battle enemy must stay above inventory tray")


func _wait_for_battle_identity(main: Control) -> void:
	for _index in range(120):
		if main.battle_stage.visible and main.battle_chibi_enemy_texture_rect.visible:
			await _settle(8)
			return
		await process_frame
	await _settle(8)


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)


func _fail(message: String) -> void:
	push_error("verify_visual_contract: %s" % message)
	quit(1)
