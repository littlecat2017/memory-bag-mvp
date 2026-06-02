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
	_verify_dialogue_sits_above_quick_bag(main)
	_verify_battle_stage_uses_upper_half(main)

	main.debug_jump_to_event("F0004")
	await _settle(12)
	_verify_travel_actor_clear_of_quick_bag(main)
	_verify_travel_actor_centered(main)

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
	_expect(hero_bottom < quick_top - 18.0, "battle hero should stand above quick bag tray")
	_expect(enemy_bottom < quick_top - 18.0, "battle enemy should stand above quick bag tray")


func _verify_dialogue_sits_above_quick_bag(main: Control) -> void:
	var quick_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	var dialogue_bottom: float = main.ui_root.size.y * 0.665
	_expect(dialogue_bottom < quick_rect.position.y - 8.0, "dialogue panel should not overlap lower quick bag tray")


func _verify_travel_actor_clear_of_quick_bag(main: Control) -> void:
	var quick_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	var travel_rect: Rect2 = main.travel_stage.get_global_rect()
	var quick_top: float = quick_rect.position.y
	var travel_bottom: float = travel_rect.end.y
	_expect(travel_bottom < quick_top - 24.0, "travel stage should not collide with lower quick bag tray")


func _verify_travel_actor_centered(main: Control) -> void:
	var actor_rect: Rect2 = main.travel_chibi_texture_rect.get_global_rect()
	var actor_center_x: float = actor_rect.get_center().x
	var screen_width: float = main.ui_root.size.x
	_expect(actor_center_x > screen_width * 0.38, "travel actor should not sit on the far left")
	_expect(actor_center_x < screen_width * 0.62, "travel actor should remain near the center")


func _verify_battle_stage_uses_upper_half(main: Control) -> void:
	var quick_rect: Rect2 = main.quick_bag_bar.get_global_rect()
	var hero_center_x: float = main.battle_chibi_hero_texture_rect.get_global_rect().get_center().x
	var enemy_center_x: float = main.battle_chibi_enemy_texture_rect.get_global_rect().get_center().x
	_expect(hero_center_x < enemy_center_x, "battle hero should stand on the left of the enemy")
	_expect(enemy_center_x - hero_center_x > main.ui_root.size.x * 0.22, "battle sides should be visually separated")
	_expect(main.battle_chibi_hero_texture_rect.get_global_rect().end.y < quick_rect.position.y - 18.0, "battle should stay above operation tray")


func _wait_for_battle_identity(main: Control) -> void:
	for _index in range(120):
		if main.battle_stage.visible and main.battle_enemy_panel.modulate.a > 0.85 and main.battle_chibi_enemy_texture_rect.visible:
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
