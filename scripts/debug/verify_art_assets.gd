extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const MainScript := preload("res://scripts/runtime/main.gd")
const MemoryCardViewScript := preload("res://scripts/ui/memory_card_view.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return
	_verify_registry(registry)
	_verify_png_files(registry)
	_verify_hero_walk_sheet_has_no_green_echo(registry)
	_verify_memory_card_icon(registry)
	await _verify_main_art_preview()
	print("verify_art_assets: ok; checked=%d" % registry.art_assets.size())
	quit(0)


func _verify_registry(registry) -> void:
	var required := [
		"bg_village_dawn",
		"bg_forest_path",
		"hero_default",
		"mother_warm",
		"master_old",
		"lia_sick",
		"elder_gray",
		"child_lost",
		"camp_shadow",
		"hunter_hollow",
		"hunter_human",
		"enemy_hollow_wolves",
		"enemy_nameless_deer",
		"enemy_hollow_warden",
		"boss_nameless_hunter",
		"chibi_party_walk_sheet",
		"chibi_hero_walk_sheet",
		"chibi_hero_attack_sheet",
		"chibi_enemy_hollow_wolves",
		"chibi_enemy_nameless_deer",
		"chibi_enemy_hollow_warden",
		"chibi_boss_nameless_hunter",
		"ui_travel_stage_panel",
		"ui_quick_bag_tray",
		"icon_memory_mothers_soup",
		"icon_memory_wooden_sword",
		"icon_memory_reason_to_depart",
		"icon_memory_my_name",
		"icon_memory_someone_waits",
		"icon_memory_abandoned_afternoon",
		"icon_memory_no_more_explaining",
		"icon_memory_empty_nameplate",
		"fx_slash_basic_sheet",
	]
	for asset_id in required:
		if not registry.art_assets.has(asset_id):
			_fail("missing art asset id: %s" % asset_id)
			return
	if registry.get_art_asset("bg_village_gate", "background").is_empty():
		_fail("background alias should resolve bg_village_gate")
		return
	if registry.get_art_asset("hero_confused", "portrait").is_empty():
		_fail("portrait alias should resolve hero_confused")
		return
	if registry.get_art_asset("master_old", "portrait").get("id", "") == "mother_warm":
		_fail("master_old should not reuse mother_warm portrait")
		return
	if registry.get_art_asset("lia_sick", "portrait").get("id", "") == "mother_warm":
		_fail("lia_sick should not reuse mother_warm portrait")
		return
	if registry.get_art_asset("enemy_hollow_wolves", "enemy").is_empty():
		_fail("enemy art should resolve enemy_hollow_wolves")
		return
	if registry.get_art_asset("boss_nameless_hunter", "enemy").is_empty():
		_fail("enemy art should resolve boss_nameless_hunter")
		return
	if registry.get_art_asset("chibi_party_walk_sheet", "chibi_sheet").is_empty():
		_fail("chibi walk sheet should resolve")
		return
	if registry.get_art_asset("chibi_hero_walk_sheet", "chibi_sheet").is_empty():
		_fail("chibi hero walk sheet should resolve")
		return
	if registry.get_art_asset("chibi_enemy_hollow_wolves", "chibi_unit").is_empty():
		_fail("chibi enemy should resolve chibi_enemy_hollow_wolves")
		return
	if registry.get_art_asset_for_memory("mem_mothers_soup").is_empty():
		_fail("memory icon should resolve mem_mothers_soup")
		return
	_verify_mvp_memory_icons_registered(registry)


func _verify_mvp_memory_icons_registered(registry) -> void:
	for memory_id in registry.memories.keys():
		var asset: Dictionary = registry.get_art_asset_for_memory(memory_id)
		if asset.is_empty():
			_fail("memory icon should resolve %s" % memory_id)
			return
		if str(asset.get("memory_id", "")) != memory_id:
			_fail("memory icon has wrong memory_id for %s" % memory_id)
			return


func _verify_png_files(registry) -> void:
	for asset_id in registry.art_assets:
		var asset: Dictionary = registry.art_assets[asset_id]
		var path := str(asset.get("path", ""))
		var image := Image.new()
		var error := image.load(path)
		if error != OK:
			_fail("image failed to load for %s: %s" % [asset_id, path])
			return
		if image.get_width() <= 0 or image.get_height() <= 0:
			_fail("image has invalid size for %s" % asset_id)
			return
		_verify_aspect(asset_id, asset, image)


func _verify_aspect(asset_id: String, asset: Dictionary, image: Image) -> void:
	var expected_size = asset.get("expected_size", [])
	if typeof(expected_size) != TYPE_ARRAY or expected_size.size() != 2:
		_fail("missing expected_size for %s" % asset_id)
		return
	var expected_ratio := float(expected_size[0]) / float(expected_size[1])
	var actual_ratio := float(image.get_width()) / float(image.get_height())
	if abs(expected_ratio - actual_ratio) > 0.08:
		_fail("image aspect mismatch for %s expected %.2f got %.2f" % [asset_id, expected_ratio, actual_ratio])
		return


func _verify_hero_walk_sheet_has_no_green_echo(registry) -> void:
	var asset: Dictionary = registry.get_art_asset("chibi_hero_walk_sheet", "chibi_sheet")
	var image := Image.new()
	if image.load(str(asset.get("path", ""))) != OK:
		_fail("hero walk sheet should load")
		return
	var frame_width := int(image.get_width() / 3)
	var frame_height := int(image.get_height() / 3)
	for frame in range(9):
		var origin := Vector2i((frame % 3) * frame_width, int(frame / 3) * frame_height)
		var suspicious_pixels := 0
		for y in range(origin.y, origin.y + frame_height):
			for x in range(origin.x, origin.x + int(frame_width * 0.25)):
				var color := image.get_pixel(x, y)
				if color.a < 0.05:
					continue
				if color.g > 0.34 and color.g > color.r + 0.07 and color.g > color.b + 0.02 and color.r < 0.75:
					suspicious_pixels += 1
		if suspicious_pixels > 40:
			_fail("hero walk sheet frame %d still has green echo residue: %d" % [frame, suspicious_pixels])
			return


func _verify_memory_card_icon(registry) -> void:
	for memory_id in registry.memories.keys():
		var card = MemoryCardViewScript.new()
		card.set_memory(
			registry.memories[memory_id],
			registry.get_art_asset_for_memory(memory_id)
		)
		if not card.has_required_memory_text():
			card.free()
			_fail("memory card should keep required text with icon for %s" % memory_id)
			return
		if not card.icon_texture_rect.visible or card.icon_texture_rect.texture == null:
			card.free()
			_fail("memory card should show icon for %s" % memory_id)
			return
		card.free()


func _verify_main_art_preview() -> void:
	var main = MainScript.new()
	get_root().add_child(main)
	await process_frame
	if not main.bg_texture_rect.visible or main.bg_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should show opening background art")
		return
	if main.dialogue_texture_rect.texture == null or main.nameplate_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should load visual novel dialogue UI art")
		return
	if main.bag_panel_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should load bag panel UI art")
		return
	if main.quick_bag_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should load image2 quick bag tray UI art")
		return
	main.debug_jump_to_event("P0012")
	await process_frame
	if not main.portrait_texture_rect.visible or main.portrait_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should show hero portrait art")
		return
	main.debug_jump_to_event("P0011")
	await process_frame
	var master_asset: Dictionary = main.registry.get_art_asset("master_old", "portrait")
	if main.portrait_texture_rect.texture == null or str(master_asset.get("id", "")) != "master_old":
		main.queue_free()
		_fail("main scene should resolve master_old as its own portrait")
		return
	main.debug_jump_to_event("F0004")
	for _index in range(3):
		await process_frame
	if not main.travel_panel_texture_rect.visible or main.travel_panel_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should load travel stage panel art")
		return
	if not main.travel_stage.visible or main.travel_chibi_texture_rect.texture == null:
		main.queue_free()
		_fail("forest travel should show chibi walking stage")
		return
	main.debug_jump_to_event("F0003")
	for _index in range(3):
		await process_frame
	if not main.battle_chibi_hero_texture_rect.visible or main.battle_chibi_hero_texture_rect.texture == null:
		main.queue_free()
		_fail("battle stage should show chibi hero texture")
		return
	if not main.battle_chibi_enemy_texture_rect.visible or main.battle_chibi_enemy_texture_rect.texture == null:
		main.queue_free()
		_fail("battle stage should show chibi enemy texture")
		return
	if main.battle_enemy_texture_rect.visible:
		main.queue_free()
		_fail("battle enemy info panel should not duplicate the stage enemy portrait")
		return
	main.queue_free()
	await process_frame


func _fail(message: String) -> void:
	push_error("verify_art_assets: %s" % message)
	quit(1)
