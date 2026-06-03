extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

const SNAPSHOT_DIR := "res://temp/ui_snapshots"
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
	await _settle()
	if not _save_snapshot("01_opening.png"):
		return
	main.debug_jump_to_event("P0034")
	await _settle()
	if not _save_snapshot("02_memory_choice.png"):
		return
	main._on_choice_pressed(0)
	await _settle()
	main._show_backpack_ui()
	main._on_bag_toggle_pressed()
	await _settle()
	if not _save_snapshot("03_bag_panel.png"):
		return
	main._on_bag_toggle_pressed()
	main.debug_jump_to_event("F0004")
	await _settle()
	main.script_player.active_stop_event_id = ""
	main.game_state.current_event_id = ""
	main.active_script_node_id = ""
	main.run_controller.start_chapter("forest")
	main.run_controller.progress = 80.0
	main.run_controller.debug_mark_nodes_before(80.0)
	main.run_controller.resume()
	main._show_backpack_ui()
	await _settle()
	if not _save_snapshot("04_travel_stage.png"):
		return
	main.debug_jump_to_event("F0003")
	await _wait_for_battle_identity(main)
	if not _save_snapshot("05_battle_stage.png"):
		return
	main.debug_jump_to_event("F0036")
	await _wait_for_battle_identity(main)
	if not _save_snapshot("06_boss_battle_stage.png"):
		return
	main._on_debug_force_ending_pressed("mvp_named_with_reason")
	await _settle()
	main._on_next_pressed()
	await _settle()
	main._on_next_pressed()
	await _settle()
	if not _save_snapshot("07_ending_summary.png"):
		return
	main.queue_free()
	viewport.queue_free()
	await process_frame
	print("capture_ui_snapshots: ok")
	quit(0)


func _settle() -> void:
	for _index in range(4):
		await process_frame


func _wait_for_battle_identity(main: Control) -> void:
	for _index in range(90):
		if main.battle_stage.visible and main.battle_enemy_panel.modulate.a > 0.85 and main.battle_chibi_enemy_texture_rect.visible:
			await _settle()
			return
		await process_frame
	await _settle()


func _save_snapshot(file_name: String) -> bool:
	var texture := viewport.get_texture()
	if texture == null:
		_fail("capture texture is null for %s" % file_name)
		return false
	var image := texture.get_image()
	if image == null:
		_fail("capture image is null for %s" % file_name)
		return false
	var error := image.save_png("%s/%s" % [SNAPSHOT_DIR, file_name])
	if error != OK:
		_fail("failed to save %s: %s" % [file_name, error])
		return false
	return true


func _fail(message: String) -> void:
	push_error("capture_ui_snapshots: %s" % message)
	if viewport != null:
		viewport.queue_free()
	quit(1)
