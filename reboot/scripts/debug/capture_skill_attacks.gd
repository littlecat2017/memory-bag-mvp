extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const SNAPSHOT_DIR := "res://temp/screenshots/skill_attacks"
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

	var index := 1
	for skill in main.PLAYER_SKILLS:
		var skill_id := str(skill.get("id", ""))
		var skill_name := str(skill.get("name", ""))
		if skill_id.is_empty():
			continue
		_prepare_skill_snapshot(main, skill)
		for frame_step in range(3):
			main._update_actor_animations(0.045)
			await _settle(2)
			if not _save_snapshot("%02d_%s_frame_%02d.png" % [index, skill_id, frame_step + 1]):
				return
		print("capture_skill_attacks: %s" % skill_name)
		index += 1

	main.queue_free()
	viewport.queue_free()
	await process_frame
	print("capture_skill_attacks: ok")
	quit(0)


func _prepare_skill_snapshot(main: Control, skill: Dictionary) -> void:
	main._stop_battle_attack_animation()
	main.current_mode = "battle"
	main.battle_active = true
	main.battle_resolved = false
	main.battle_phase = "player"
	main.hero_hp = main.hero_max_hp
	main.enemy_hp = main.enemy_max_hp
	main.current_skill = skill
	main.current_attack_is_skill = true
	main._show_skill_banner(str(skill.get("name", "")))
	main._start_battle_attack_animation({
		"type": "skill",
		"id": str(skill.get("id", "")),
		"name": str(skill.get("name", "")),
		"slash_frames": main._skill_slash_frames(str(skill.get("id", ""))),
	})
	main._refresh_battle_ui()
	main.show_mode("battle")


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


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _fail(message: String) -> bool:
	push_error("capture_skill_attacks: %s" % message)
	if viewport != null:
		viewport.queue_free()
	quit(1)
	return false
