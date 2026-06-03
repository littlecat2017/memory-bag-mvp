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
	if not _save_snapshot("00_title_graybox.png"):
		return

	main.jump_to_event("T0001")
	await _settle(4)
	if not _save_snapshot("01_dialogue_graybox.png"):
		return

	main.jump_to_event("F0010")
	await _settle(4)
	if not _save_snapshot("02_travel_graybox.png"):
		return

	main.jump_to_event("F0003")
	await _settle(4)
	if not _save_snapshot("03_battle_graybox.png"):
		return

	main.advance_battle()
	await _settle(4)
	if not _save_snapshot("03b_battle_resolved_graybox.png"):
		return

	main.show_mode("bag_detail")
	await _settle(4)
	if not _save_snapshot("04_bag_detail_graybox.png"):
		return

	main.show_mode("ending")
	await _settle(4)
	if not _save_snapshot("05_ending_graybox.png"):
		return

	main.start_script()
	for _index in range(38):
		if str(main.current_event.get("id", "")) == "P0034":
			break
		main.advance_script()
	await _settle(4)
	if not _save_snapshot("06_script_choice_graybox.png"):
		return

	main.choose_option(0)
	await _settle(4)
	if not _save_snapshot("07_script_choice_result_graybox.png"):
		return

	main.jump_to_event("F0010")
	main.choose_option(0)
	await _settle(4)
	if not _save_snapshot("08_memory_replace_graybox.png"):
		return

	main.replace_memory_at(0)
	await _settle(4)
	if not _save_snapshot("09_memory_replace_result_graybox.png"):
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
