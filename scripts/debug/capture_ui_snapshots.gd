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
	_save_snapshot("01_opening.png")
	main.debug_jump_to_event("P0034")
	await _settle()
	_save_snapshot("02_memory_choice.png")
	main._on_choice_pressed(0)
	await _settle()
	main._on_bag_toggle_pressed()
	await _settle()
	_save_snapshot("03_bag_panel.png")
	main._on_bag_toggle_pressed()
	main.debug_jump_to_event("F0003")
	await _settle()
	_save_snapshot("04_battle_stage.png")
	main._on_debug_force_ending_pressed("mvp_named_with_reason")
	await _settle()
	main._on_next_pressed()
	await _settle()
	main._on_next_pressed()
	await _settle()
	_save_snapshot("05_ending_summary.png")
	main.queue_free()
	viewport.queue_free()
	await process_frame
	print("capture_ui_snapshots: ok")
	quit(0)


func _settle() -> void:
	for _index in range(4):
		await process_frame


func _save_snapshot(file_name: String) -> void:
	var image := viewport.get_texture().get_image()
	image.save_png("%s/%s" % [SNAPSHOT_DIR, file_name])
