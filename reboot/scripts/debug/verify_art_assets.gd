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
	_expect(not main.stage_background_tiles.is_empty(), "stage background tiles exist")
	_expect(main.stage_background_tiles[0].texture != null, "scrolling stage background texture")
	_expect(main.stage_background_tiles[0].texture.get_width() == 2048 and main.stage_background_tiles[0].texture.get_height() == 512, "scrolling stage background is normalized")
	_expect(main.stage_background_textures.size() == 10, "ten scrolling stage maps are loaded")
	for texture in main.stage_background_textures:
		_expect(texture.get_width() == 2048 and texture.get_height() == 512, "stage map texture is normalized")
	_expect(main.title_background_art.texture != null, "title background texture")
	_expect(main.dialogue_panel_art.texture != null, "dialogue panel texture")
	_expect(main.hero_art.texture != null, "hero texture")
	_expect(main.enemy_art.texture != null, "enemy texture")
	_expect(main.enemy_textures.size() == main.GAMEPLAY_ENEMY_IDS.size(), "ten gameplay enemy textures are loaded")
	for enemy_id in main.GAMEPLAY_ENEMY_IDS:
		var enemy_texture: Texture2D = main.enemy_textures.get(str(enemy_id), null)
		_expect(enemy_texture != null, "%s enemy texture is loaded" % enemy_id)
		if enemy_texture != null:
			_expect(enemy_texture.get_width() == 512 and enemy_texture.get_height() == 512, "%s enemy texture is normalized" % enemy_id)
			_expect(_texture_has_clean_border(enemy_texture), "%s enemy texture has transparent borders" % enemy_id)
	_expect(main.hero_walk_sheet_texture != null, "hero walk animation sheet texture")
	_expect(main.hero_attack_sheet_texture != null, "hero attack animation sheet texture")
	_expect(main.enemy_idle_sheet_texture != null, "enemy idle animation sheet texture")
	_expect(main.enemy_hit_sheet_texture != null, "enemy hit animation sheet texture")
	_expect(main.slash_effect_sheet_texture != null, "slash effect animation sheet texture")
	_expect(main.skill_slash_sheet_textures.size() == main.PLAYER_SKILLS.size(), "skill slash sheet textures are loaded")
	_expect(main.hit_burst_sheet_texture != null, "hit burst animation sheet texture")
	_expect(main.hero_walk_frames.size() == 9, "hero walk animation frames are cached")
	var walk_frame_1 := main.hero_walk_frames[0] as AtlasTexture
	var walk_frame_3 := main.hero_walk_frames[2] as AtlasTexture
	var walk_frame_4 := main.hero_walk_frames[3] as AtlasTexture
	_expect(walk_frame_1.region.position == Vector2(0, 0), "walk frame 1 is top-left")
	_expect(walk_frame_3.region.position == Vector2(512, 0), "walk frame 3 is top-right")
	_expect(walk_frame_4.region.position == Vector2(0, 256), "walk frame 4 starts second row")
	_expect(main.hero_attack_frames.size() == 8, "hero attack animation frames are cached")
	_expect(main.enemy_idle_frames.size() == 8, "enemy idle animation frames are cached")
	_expect(main.enemy_hit_frames.size() == 6, "enemy hit animation frames are cached")
	_expect(main.slash_effect_frames.size() == 6, "slash effect animation frames are cached")
	for skill in main.PLAYER_SKILLS:
		var skill_id := str(skill.get("id", ""))
		var frames: Array[Texture2D] = main._skill_slash_frames(skill_id)
		_expect(frames.size() == 6, "%s skill slash frames are cached" % skill_id)
	_expect(main.hit_burst_frames.size() == 8, "hit burst animation frames are cached")
	_expect(main.hero_walk_sheet_texture.get_width() == 768 and main.hero_walk_sheet_texture.get_height() == 768, "hero walk sheet has ordered 3x3 256px frames")
	_expect(main.hero_attack_sheet_texture.get_width() == 2048 and main.hero_attack_sheet_texture.get_height() == 256, "hero attack sheet has 8 256px frames")
	_expect(main.enemy_hit_sheet_texture.get_width() == 1536 and main.enemy_hit_sheet_texture.get_height() == 256, "enemy hit sheet has 6 256px frames")
	_expect(main.slash_effect_sheet_texture.get_width() == 1536 and main.slash_effect_sheet_texture.get_height() == 160, "slash sheet has 6 256x160 frames")
	for skill in main.PLAYER_SKILLS:
		var skill_id := str(skill.get("id", ""))
		var texture: Texture2D = main.skill_slash_sheet_textures.get(skill_id, null)
		_expect(texture != null and texture.get_width() == 1536 and texture.get_height() == 160, "%s skill slash sheet has 6 256x160 frames" % skill_id)
	_expect(main.hit_burst_sheet_texture.get_width() == 1536 and main.hit_burst_sheet_texture.get_height() == 192, "hit burst sheet has 8 192px frames")
	_expect(main.memory_icons_texture != null, "memory icon atlas texture")
	_expect(main.memory_item_textures.size() == main.MEMORY_GRID_SIZES.size(), "all spatial memory item textures load")
	_expect(main._memory_item_texture("mem_wooden_sword") != main._memory_icon_texture("mem_wooden_sword"), "wooden sword uses dedicated spatial item art")

	main.start_script()
	await process_frame
	_expect(main.inventory_cell_icons.size() == 36, "inventory has icon holders")
	_expect(main.inventory_item_layer.get_child_count() == 4, "owned memories render as item overlays")
	_expect(main._memory_grid_size("mem_wooden_sword") == Vector2i(4, 1), "wooden sword uses a multi-cell footprint")
	var sword_texture: Texture2D = main._memory_item_texture("mem_wooden_sword")
	_expect(sword_texture != null and sword_texture.get_width() > sword_texture.get_height() * 3, "wooden sword item art matches its horizontal footprint")
	_expect(_rendered_item_matches_grid(main, "mem_wooden_sword"), "wooden sword rendered item matches its grid footprint")
	_expect(_rendered_item_matches_grid(main, "mem_reason_to_depart"), "reason journal rendered item matches its grid footprint")
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


func _rendered_item_matches_grid(main: Control, memory_id: String) -> bool:
	var position: Vector2i = main._memory_grid_position(memory_id)
	if position.x < 0:
		return false
	var size: Vector2i = main._memory_grid_size(memory_id)
	var expected_rect: Rect2 = main._memory_item_visual_rect(main.inventory_item_layer.size, position, size)
	for child in main.inventory_item_layer.get_children():
		if child is Control and str(child.tooltip_text) == main._memory_name(memory_id):
			var rect := Rect2(child.position, child.size)
			return rect.position.distance_to(expected_rect.position) <= 1.0 and rect.size.distance_to(expected_rect.size) <= 1.0
	return false


func _texture_matches_grid(main: Control, memory_id: String) -> bool:
	var texture: Texture2D = main._memory_item_texture(memory_id)
	if texture == null:
		return false
	var size: Vector2i = main._memory_grid_size(memory_id)
	var expected_aspect: float = float(size.x) / float(size.y)
	var texture_aspect: float = float(texture.get_width()) / float(texture.get_height())
	return abs(texture_aspect - expected_aspect) <= 0.45


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
