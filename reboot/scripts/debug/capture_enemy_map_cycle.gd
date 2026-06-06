extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const SNAPSHOT_DIR := "res://temp/screenshots/enemy_map_cycle"
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
	main.start_script()
	await _settle(4)

	for encounter_index in range(main.GAMEPLAY_ENEMY_IDS.size()):
		await _drive_to_battle(main)
		await _settle(4)
		var enemy_id: String = str(main.battle_enemy_id)
		var map_index: int = int(main.current_stage_map_index) + 1
		if not _save_snapshot("%02d_map_%02d_%s.png" % [encounter_index + 1, map_index, enemy_id]):
			return
		await _resolve_current_battle(main)
		await _settle(4)

	main.queue_free()
	viewport.queue_free()
	await process_frame
	print("capture_enemy_map_cycle: ok")
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


func _drive_to_battle(main: Control) -> void:
	for _step in range(28):
		if main.current_mode == "battle":
			return
		main._update_opening_travel(0.5)
		await process_frame


func _resolve_current_battle(main: Control) -> void:
	for _step in range(260):
		if main.current_mode == "travel":
			return
		if main._battle_animation_active():
			main._update_actor_animations(0.05)
		else:
			main._update_battle_turn_flow(0.05)
		await process_frame


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _fail(message: String) -> bool:
	push_error("capture_enemy_map_cycle: %s" % message)
	if viewport != null:
		viewport.queue_free()
	quit(1)
	return false
