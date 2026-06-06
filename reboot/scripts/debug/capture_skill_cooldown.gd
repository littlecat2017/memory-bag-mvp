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

	main.start_script()
	await _drive_to_battle(main)
	await _settle(4)
	main._stop_battle_attack_animation()
	main.battle_resolved = false
	main.battle_active = true
	main.battle_phase = "player"
	main.enemy_hp = main.enemy_max_hp
	main.normal_attack_counter = main.SKILL_TRIGGER_NORMAL_ATTACKS
	main._perform_player_battle_turn()
	await _settle(2)
	main._update_actor_animations(0.045)
	await _settle(2)

	if not _save_snapshot("09_skill_cooldown_art.png"):
		return
	main.queue_free()
	viewport.queue_free()
	await process_frame
	print("capture_skill_cooldown: ok")
	quit(0)


func _drive_to_battle(main: Control) -> void:
	for _step in range(28):
		if main.current_mode == "battle":
			return
		main._update_opening_travel(0.5)
		await process_frame


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


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _fail(message: String) -> bool:
	push_error("capture_skill_cooldown: %s" % message)
	if viewport != null:
		viewport.queue_free()
	quit(1)
	return false
