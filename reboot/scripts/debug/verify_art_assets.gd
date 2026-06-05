extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("verify_art_assets: instantiate")
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	await process_frame
	print("verify_art_assets: ready")

	_expect(main.validation_errors.is_empty(), "no validation errors")
	_expect(main.screen_background_art.texture != null, "gameplay shell texture")
	_expect(main.title_background_art.texture != null, "title background texture")
	_expect(main.dialogue_panel_art.texture != null, "dialogue panel texture")
	_expect(main.hero_art.texture != null, "hero texture")
	_expect(main.enemy_art.texture != null, "enemy texture")
	_expect(main.memory_icons_texture != null, "memory icon atlas texture")
	_expect(main.memory_item_textures.size() == main.MEMORY_GRID_SIZES.size(), "all spatial memory item textures load")
	_expect(main._memory_item_texture("mem_wooden_sword") != main._memory_icon_texture("mem_wooden_sword"), "wooden sword uses dedicated spatial item art")

	main.start_script()
	for _index in range(38):
		if str(main.current_event.get("id", "")) == "P0034":
			break
		main.advance_script()
	main.choose_option(0)
	await process_frame
	_expect(main.inventory_cell_icons.size() == 36, "inventory has icon holders")
	_expect(main.inventory_item_layer.get_child_count() == 4, "owned memories render as item overlays")
	_expect(main._memory_grid_size("mem_wooden_sword") == Vector2i(4, 1), "wooden sword uses a multi-cell footprint")
	var sword_texture: Texture2D = main._memory_item_texture("mem_wooden_sword")
	_expect(sword_texture != null and sword_texture.get_width() > sword_texture.get_height() * 3, "wooden sword item art matches its horizontal footprint")
	_expect(_texture_matches_grid(main, "mem_wooden_sword"), "wooden sword texture dimensions match its grid footprint")
	_expect(_texture_matches_grid(main, "mem_reason_to_depart"), "reason journal texture dimensions match its grid footprint")
	for memory_id in main.MEMORY_GRID_SIZES.keys():
		var typed_id := str(memory_id)
		_expect(_texture_has_clean_border(main._memory_item_texture(typed_id)), "%s item texture has transparent borders" % typed_id)

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_art_assets: ok")
	quit(0)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_art_assets: %s" % message)


func _texture_matches_grid(main: Control, memory_id: String) -> bool:
	var texture: Texture2D = main._memory_item_texture(memory_id)
	if texture == null:
		return false
	var size: Vector2i = main._memory_grid_size(memory_id)
	var expected_width: int = size.x * 72 + maxi(0, size.x - 1) * 8
	var expected_height: int = size.y * 64 + maxi(0, size.y - 1) * 8
	return texture.get_width() == expected_width and texture.get_height() == expected_height


func _texture_has_clean_border(texture: Texture2D) -> bool:
	if texture == null:
		return false
	var image := texture.get_image()
	if image == null or image.is_empty():
		return false
	var width := image.get_width()
	var height := image.get_height()
	for x in range(width):
		if image.get_pixel(x, 0).a > 0.08 or image.get_pixel(x, height - 1).a > 0.08:
			return false
	for y in range(height):
		if image.get_pixel(0, y).a > 0.08 or image.get_pixel(width - 1, y).a > 0.08:
			return false
	return true
