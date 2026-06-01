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
		"icon_memory_mothers_soup",
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
	if registry.get_art_asset_for_memory("mem_mothers_soup").is_empty():
		_fail("memory icon should resolve mem_mothers_soup")
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


func _verify_memory_card_icon(registry) -> void:
	var card = MemoryCardViewScript.new()
	card.set_memory(
		registry.memories["mem_mothers_soup"],
		registry.get_art_asset_for_memory("mem_mothers_soup")
	)
	if not card.has_required_memory_text():
		card.free()
		_fail("memory card should keep required text with icon")
		return
	if not card.icon_texture_rect.visible or card.icon_texture_rect.texture == null:
		card.free()
		_fail("memory card should show soup icon")
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
	main.debug_jump_to_event("P0012")
	await process_frame
	if not main.portrait_texture_rect.visible or main.portrait_texture_rect.texture == null:
		main.queue_free()
		_fail("main scene should show hero portrait art")
		return
	main.queue_free()
	await process_frame


func _fail(message: String) -> void:
	push_error("verify_art_assets: %s" % message)
	quit(1)
