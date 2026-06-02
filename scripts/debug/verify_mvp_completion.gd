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

	_expect(main.game_state.current_event_id == "T0001", "MVP should open with tutorial T0001")
	_expect(main.system_hint_panel.visible, "tutorial should show a dedicated hint panel")
	_expect(main.system_hint_body_label.text.contains("自动前进"), "tutorial hint should explain auto travel/combat")
	_expect(not main.debug_toggle_button.visible, "release-facing UI should hide the debug entry")

	main.game_state.gain_memory("mem_wooden_sword")
	main.game_state.gain_memory("mem_reason_to_depart")
	main.game_state.gain_memory("mem_my_name")
	main.game_state.gain_memory("mem_mothers_soup")
	main._discard_memory_from_drag("mem_mothers_soup")
	main._show_backpack_ui()
	await _settle(4)
	_expect(main.world_feedback_panel.visible, "discarding memory should reveal world feedback in backpack mode")
	_expect(main.world_feedback_label.text.contains("母亲做的热汤"), "world feedback should mention the discarded memory")

	main.game_state.hp = 1
	main.debug_jump_to_event("F0036")
	await _settle(8)
	for _index in range(160):
		if not main.battle_stage.visible and not main.game_state.world_feedback_history.is_empty():
			break
		await process_frame
	_expect(_feedback_contains(main, "濒死回退"), "defeat recovery should be recorded as world feedback")

	main.queue_free()
	await process_frame
	print("verify_mvp_completion: ok")
	quit(0)


func _feedback_contains(main: Control, needle: String) -> bool:
	for value in main.game_state.world_feedback_history:
		if str(value).contains(needle):
			return true
	return false


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)


func _fail(message: String) -> void:
	push_error("verify_mvp_completion: %s" % message)
	quit(1)
