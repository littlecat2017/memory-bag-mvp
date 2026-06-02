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

	main.debug_jump_to_event("F0003")
	await _wait_for_battle_identity(main)
	_verify_quick_bag_does_not_block_battle_feet(main)
	_verify_quick_bag_sits_above_dialogue(main)

	main.debug_jump_to_event("F0004")
	await _settle(12)
	_verify_travel_actor_clear_of_quick_bag(main)

	main.queue_free()
	await process_frame
	print("verify_visual_layout_bounds: ok")
	quit(0)


func _verify_quick_bag_does_not_block_battle_feet(main: Control) -> void:
	var quick_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	var hero_rect: Rect2 = main.battle_chibi_hero_texture_rect.get_global_rect()
	var enemy_rect: Rect2 = main.battle_chibi_enemy_texture_rect.get_global_rect()
	var quick_top: float = quick_rect.position.y
	var hero_bottom: float = hero_rect.end.y
	var enemy_bottom: float = enemy_rect.end.y
	_expect(hero_bottom < quick_top - 4.0, "battle hero should stand above quick bag strip")
	_expect(enemy_bottom < quick_top - 4.0, "battle enemy should stand above quick bag strip")


func _verify_quick_bag_sits_above_dialogue(main: Control) -> void:
	var quick_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	var dialogue_top: float = main.ui_root.size.y * 0.67
	var quick_bottom: float = quick_rect.end.y
	_expect(quick_bottom < dialogue_top - 4.0, "quick bag should not overlap dialogue panel")


func _verify_travel_actor_clear_of_quick_bag(main: Control) -> void:
	var quick_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	var travel_rect: Rect2 = main.travel_stage.get_global_rect()
	var quick_top: float = quick_rect.position.y
	var travel_bottom: float = travel_rect.end.y
	_expect(travel_bottom < quick_top - 8.0, "travel inset should not collide with quick bag")


func _wait_for_battle_identity(main: Control) -> void:
	for _index in range(120):
		if main.battle_stage.visible and main.battle_enemy_panel.modulate.a > 0.85 and main.battle_enemy_texture_rect.visible:
			await _settle(6)
			return
		await process_frame
	await _settle(6)


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)


func _fail(message: String) -> void:
	push_error("verify_visual_layout_bounds: %s" % message)
	quit(1)
