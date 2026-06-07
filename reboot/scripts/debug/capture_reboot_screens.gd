extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const SNAPSHOT_DIR := "res://temp/screenshots"
const SNAPSHOT_SIZE := Vector2i(1280, 720)

var viewport: SubViewport


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SNAPSHOT_DIR))
	viewport = SubViewport.new()
	viewport.size = SNAPSHOT_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(viewport)

	var main: Control = MainScene.instantiate()
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.size = Vector2(SNAPSHOT_SIZE)
	viewport.add_child(main)
	await _settle(8)

	main.show_mode("title")
	await _settle(4)
	if not _save_snapshot("00_title_art.png"):
		return

	main.start_script()
	await _settle(4)
	if not _save_snapshot("00b_prologue_art.png"):
		return
	await _finish_prologue(main)
	main._update_opening_travel(1.2)
	await _settle(4)
	if not _save_snapshot("01_opening_walk_art.png"):
		return
	main.cycle_stage_map(1)
	await _settle(4)
	if not _save_snapshot("01b_manual_map_switch_art.png"):
		return

	await _drive_to_battle(main)
	await _settle(4)
	if not _save_snapshot("02_battle_idle_art.png"):
		return

	await _wait_for_player_attack(main)
	await _settle(2)
	if not _save_snapshot("03_battle_attack_art.png"):
		return
	if not await _save_enemy_counter_snapshot(main, "04_battle_enemy_counter_art.png"):
		return
	if not await _wait_for_victory_snapshot(main):
		return
	await _settle(4)
	if not _save_snapshot("05_battle_victory_art.png"):
		return

	await _wait_for_travel(main)
	await _settle(4)
	if not _save_snapshot("06_growth_reward_travel_art.png"):
		return
	main._accept_pending_equipment()
	main.player_attribute_points = max(main.player_attribute_points, 1)
	main._spend_attribute_point("strength")
	await _settle(4)
	if not _save_snapshot("07_growth_panel_after_choice_art.png"):
		return

	await _drive_to_battle(main)
	await _settle(4)
	if not _save_snapshot("08_second_map_battle_art.png"):
		return
	if not await _resolve_current_battle(main):
		return
	await _wait_for_travel(main)
	await _settle(4)
	if not _save_snapshot("09_third_map_travel_art.png"):
		return

	main.queue_free()
	viewport.queue_free()
	await process_frame
	print("capture_reboot_screens: ok")
	quit(0)


func _save_snapshot(file_name: String) -> bool:
	var texture := viewport.get_texture()
	if texture == null:
		return _fail("capture texture is null for %s" % file_name)
	var image := texture.get_image()
	if image == null:
		return _fail("capture image is null for %s" % file_name)
	var error := image.save_png("%s/%s" % [SNAPSHOT_DIR, file_name])
	if error != OK:
		return _fail("failed to save %s: %s" % [file_name, error])
	return true


func _fail(message: String) -> bool:
	push_error("capture_reboot_screens: %s" % message)
	if viewport != null:
		viewport.queue_free()
	quit(1)
	return false


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _finish_prologue(main: Control) -> void:
	for _line_index in range(main.PROLOGUE_LINES.size() + 2):
		if main.current_mode != "prologue":
			return
		main.advance_by_pointer()
		await process_frame


func _drive_to_battle(main: Control) -> void:
	for _step in range(24):
		if main.current_mode == "battle":
			return
		main._update_opening_travel(0.5)
		await process_frame


func _save_enemy_counter_snapshot(main: Control, file_name: String) -> bool:
	for _frame in range(40):
		main._update_actor_animations(0.05)
		main._update_battle_turn_flow(0.05)
		await process_frame
		if main.enemy_attack_active:
			return _save_snapshot(file_name)
	return _save_snapshot(file_name)


func _wait_for_player_attack(main: Control) -> void:
	for _frame in range(40):
		main._update_battle_turn_flow(0.05)
		main._update_actor_animations(0.05)
		await process_frame
		if main.hero_attack_active:
			return


func _wait_for_travel(main: Control) -> void:
	for _frame in range(80):
		if main.current_mode == "travel":
			return
		if main._battle_animation_active():
			main._update_actor_animations(0.05)
		else:
			main._update_battle_turn_flow(0.05)
		await process_frame


func _wait_for_victory_snapshot(main: Control) -> bool:
	for _step in range(240):
		if main.current_mode == "travel":
			return _fail("battle auto-continued before victory snapshot")
		if main.battle_resolved and not main._battle_animation_active():
			return true
		if main._battle_animation_active():
			main._update_actor_animations(0.05)
		else:
			main._update_battle_turn_flow(0.05)
		await process_frame
	return _fail("battle did not reach victory")


func _resolve_current_battle(main: Control) -> bool:
	for _step in range(240):
		if main.current_mode == "travel":
			return true
		if main._battle_animation_active():
			main._update_actor_animations(0.05)
		else:
			main._update_battle_turn_flow(0.05)
		await process_frame
	return _fail("battle did not resolve")
