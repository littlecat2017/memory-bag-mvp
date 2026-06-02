extends SceneTree

const MainScene := preload("res://scenes/main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.size = Vector2(1280, 720)
	await _settle(12)

	main.debug_jump_to_event("F0004")
	await _settle(12)
	await _wait_seconds(4.0)

	main.debug_jump_to_event("F0003")
	await _wait_for_battle_identity(main)
	await _wait_seconds(7.0)

	main.debug_jump_to_event("F0036")
	await _wait_for_battle_identity(main)
	await _wait_seconds(7.0)

	main.queue_free()
	await process_frame
	print("capture_motion_review: ok")
	quit(0)


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _wait_seconds(seconds: float) -> void:
	var frames := int(ceil(seconds * 30.0))
	await _settle(frames)


func _wait_for_battle_identity(main: Control) -> void:
	for _index in range(120):
		if main.battle_stage.visible and main.battle_enemy_panel.modulate.a > 0.85 and main.battle_enemy_texture_rect.visible:
			await _settle(6)
			return
		await process_frame
	await _settle(6)
