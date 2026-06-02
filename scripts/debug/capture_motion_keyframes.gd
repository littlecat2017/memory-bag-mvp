extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

const OUTPUT_DIR := "res://temp/motion_review/keyframes"
const SHEET_PATH := "res://temp/motion_review/keyframes_contact_sheet.png"
const FRAME_SIZE := Vector2i(320, 180)
const COLUMNS := 4

var captures: Array[Dictionary] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.size = Vector2(1280, 720)
	await _settle(12)

	main.debug_jump_to_event("F0004")
	await _settle(12)
	await _capture_after("walk 0.4s", 12)
	await _capture_after("walk 1.2s", 24)
	await _capture_after("walk 2.0s", 24)
	await _capture_after("walk 3.0s", 30)

	main.debug_jump_to_event("F0003")
	await _wait_for_battle_identity(main)
	await _capture_after("battle appear", 1)
	await _capture_after("hero dash", 30)
	await _capture_after("slash no block", 9)
	await _capture_after("enemy settle", 30)

	main.debug_jump_to_event("F0036")
	await _wait_for_battle_identity(main)
	await _capture_after("boss appear", 1)
	await _capture_after("boss pressure", 24)
	await _capture_after("boss slash", 36)
	await _capture_after("boss settle", 42)

	_write_contact_sheet()
	main.queue_free()
	await process_frame
	print("capture_motion_keyframes: ok")
	quit(0)


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _capture_after(label: String, frames: int) -> void:
	await _settle(frames)
	var image := get_root().get_texture().get_image()
	var file_name := "%02d_%s.png" % [captures.size() + 1, label.replace(" ", "_")]
	var path := "%s/%s" % [OUTPUT_DIR, file_name]
	image.save_png(path)
	captures.append({"label": label, "path": path})


func _wait_for_battle_identity(main: Control) -> void:
	for _index in range(120):
		if main.battle_stage.visible and main.battle_enemy_panel.modulate.a > 0.85 and main.battle_chibi_enemy_texture_rect.visible:
			await _settle(6)
			return
		await process_frame
	await _settle(6)


func _write_contact_sheet() -> void:
	var rows := int(ceil(float(captures.size()) / float(COLUMNS)))
	var sheet := Image.create(FRAME_SIZE.x * COLUMNS, FRAME_SIZE.y * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.04, 0.04, 0.04, 1.0))
	for index in range(captures.size()):
		var image := Image.new()
		if image.load(str(captures[index].get("path", ""))) != OK:
			continue
		image.resize(FRAME_SIZE.x, FRAME_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var target := Vector2i((index % COLUMNS) * FRAME_SIZE.x, int(index / COLUMNS) * FRAME_SIZE.y)
		sheet.blit_rect(image, Rect2i(Vector2i.ZERO, FRAME_SIZE), target)
	sheet.save_png(SHEET_PATH)
