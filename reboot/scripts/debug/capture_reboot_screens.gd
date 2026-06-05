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

	main.jump_to_event("T0001")
	await _settle(4)
	if not _save_snapshot("01_dialogue_art.png"):
		return

	await _prepare_standard_opening(main)
	main.jump_to_event("P0035A")
	main.show_mode("travel")
	await _settle(4)
	if not _save_snapshot("02_travel_art.png"):
		return

	main.jump_to_event("F0003")
	await _settle(4)
	if not _save_snapshot("03_battle_art.png"):
		return

	main.advance_battle()
	await _settle(2)
	if not _save_snapshot("03a_battle_attack_art.png"):
		return
	await _settle(4)
	if not _save_snapshot("03b_battle_resolved_art.png"):
		return

	main.show_mode("bag_detail")
	await _settle(4)
	if not _save_snapshot("04_bag_detail_art.png"):
		return

	main.show_mode("ending")
	await _settle(4)
	if not _save_snapshot("05_ending_art.png"):
		return

	main.start_script()
	for _index in range(38):
		if str(main.current_event.get("id", "")) == "P0034":
			break
		main.advance_script()
	await _settle(4)
	if not _save_snapshot("06_script_choice_art.png"):
		return

	main.choose_option(0)
	await _settle(4)
	if not _save_snapshot("07_script_choice_result_art.png"):
		return

	main.jump_to_event("F0010")
	main.choose_option(0)
	main.show_mode("travel")
	await _settle(4)
	if not _save_snapshot("08_spatial_pickup_art.png"):
		return

	main.move_memory_to("mem_wooden_sword", Vector2i(0, 3))
	main.show_mode("travel")
	await _settle(4)
	if not _save_snapshot("09_spatial_rearrange_art.png"):
		return

	if not await _run_hero_playthrough(main):
		return
	await _settle(4)
	if not _save_snapshot("10_mvp_ending_art.png"):
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


func _prepare_standard_opening(main: Control) -> void:
	main.start_script()
	for _index in range(38):
		if str(main.current_event.get("id", "")) == "P0034":
			break
		main.advance_script()
	main.choose_option(0)
	await _settle(4)


func _run_hero_playthrough(main: Control) -> bool:
	main.start_script()
	for _step in range(600):
		if main.current_mode == "ending" and str(main.current_event.get("id", "")).begins_with("E"):
			return true
		match main.current_mode:
			"battle":
				if main._battle_animation_active():
					main._update_actor_animations(0.05)
				else:
					main.advance_battle()
			"choice":
				_choose_hero_option(main)
			"memory_replace":
				main.replace_memory_at(_replacement_slot(main))
			"dialogue", "travel":
				main.advance_script()
			"ending":
				return true
			_:
				main.advance_script()
		await process_frame
	return _fail("hero playthrough did not reach an ending")


func _choose_hero_option(main: Control) -> void:
	var targets := {
		"P0034": "P0035A",
		"F0010": "F0011A",
		"F0021": "F0022B",
		"F0034": "F0035A",
		"M0010": "M0011B",
		"M0017": "M0018B",
		"M0020": "M0021B",
		"C0011": "C0012D",
		"C0022": "C0023B",
		"C0029": "C0030D",
		"K0020": "K0021A",
		"K0026": "EVAL_ENDING",
	}
	var target := str(targets.get(str(main.current_event.get("id", "")), ""))
	for index in range(main.available_choice_options.size()):
		var option: Dictionary = main.available_choice_options[index]
		if str(option.get("target", "")) == target:
			main.choose_option(index)
			return
	main.choose_option(0)


func _replacement_slot(main: Control) -> int:
	var protected_memories := ["mem_mothers_soup", "mem_reason_to_depart", "mem_my_name"]
	for index in range(main.owned_memory_ids.size()):
		if not protected_memories.has(str(main.owned_memory_ids[index])):
			return index
	return 0
