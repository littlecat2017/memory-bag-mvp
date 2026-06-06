extends SceneTree

const SOURCE_SHEET := "res://assets/generated/mvp_art/actor_anim/slash_effect_sheet.png"
const OUTPUT_ROOT := "res://assets/generated/mvp_art/actor_anim/skills/"
const FRAME_SIZE := Vector2i(256, 160)
const FRAME_COUNT := 6

const SKILL_SPECS := [
	{
		"path": OUTPUT_ROOT + "skill_slash_dawn_sheet.png",
		"core": Color(1.00, 0.58, 0.08, 1.0),
		"highlight": Color(1.00, 0.93, 0.24, 1.0),
		"outline": Color(0.42, 0.13, 0.00, 1.0),
		"accent": Color(1.00, 0.82, 0.24, 1.0),
		"style": "dawn",
	},
	{
		"path": OUTPUT_ROOT + "skill_slash_paper_rain_sheet.png",
		"core": Color(0.42, 0.45, 1.00, 1.0),
		"highlight": Color(0.92, 0.88, 1.00, 1.0),
		"outline": Color(0.12, 0.10, 0.42, 1.0),
		"accent": Color(0.72, 0.82, 1.00, 1.0),
		"style": "paper",
	},
	{
		"path": OUTPUT_ROOT + "skill_slash_lantern_spin_sheet.png",
		"core": Color(0.00, 0.82, 0.58, 1.0),
		"highlight": Color(0.52, 1.00, 0.82, 1.0),
		"outline": Color(0.00, 0.25, 0.20, 1.0),
		"accent": Color(1.00, 0.86, 0.24, 1.0),
		"style": "lantern",
	},
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var source: Image = Image.load_from_file(SOURCE_SHEET)
	if source == null:
		push_error("failed to load %s" % SOURCE_SHEET)
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	for spec in SKILL_SPECS:
		if not _generate_sheet(source, spec):
			quit(1)
			return
	print("generate_skill_slash_assets: ok")
	quit(0)


func _generate_sheet(source: Image, spec: Dictionary) -> bool:
	var output := Image.create(FRAME_SIZE.x * FRAME_COUNT, FRAME_SIZE.y, false, Image.FORMAT_RGBA8)
	var core: Color = spec.get("core", Color.WHITE)
	var highlight: Color = spec.get("highlight", Color.WHITE)
	var outline: Color = spec.get("outline", Color.BLACK)
	var accent: Color = spec.get("accent", Color.WHITE)
	var style := str(spec.get("style", ""))
	for frame in range(FRAME_COUNT):
		_copy_recolored_frame(source, output, frame, core, highlight, outline)
		match style:
			"dawn":
				_draw_dawn_accents(output, frame, accent, outline)
			"paper":
				_draw_paper_accents(output, frame, accent, outline)
			"lantern":
				_draw_lantern_accents(output, frame, accent, outline)
	var path := str(spec.get("path", ""))
	var error: Error = output.save_png(path)
	if error != OK:
		push_error("failed to save %s: %s" % [path, error])
		return false
	print("generated %s" % path)
	return true


func _copy_recolored_frame(source: Image, output: Image, frame: int, core: Color, highlight: Color, outline: Color) -> void:
	var ox := frame * FRAME_SIZE.x
	for y in range(FRAME_SIZE.y):
		for x in range(FRAME_SIZE.x):
			var sx := ox + x
			var color: Color = source.get_pixel(sx, y)
			var neighbor_alpha := _neighbor_alpha(source, sx, y, source.get_width(), source.get_height())
			if color.a <= 0.012:
				if neighbor_alpha > 0.08:
					output.set_pixel(sx, y, Color(outline.r, outline.g, outline.b, min(0.68, neighbor_alpha * 0.82)))
				continue
			var luminance: float = clamp((color.r + color.g + color.b) / 3.0, 0.0, 1.0)
			var tone: Color = core.lerp(highlight, pow(luminance, 0.75))
			var alpha: float = clamp(color.a * 1.92 + 0.14, 0.0, 1.0)
			output.set_pixel(sx, y, Color(tone.r, tone.g, tone.b, alpha))


func _draw_dawn_accents(image: Image, frame: int, accent: Color, outline: Color) -> void:
	var ox := frame * FRAME_SIZE.x
	var shift := float(frame) * 7.0
	_draw_line(image, Vector2(ox + 46 + shift, 118), Vector2(ox + 206 + shift, 42), 5.0, outline, 0.72)
	_draw_line(image, Vector2(ox + 44 + shift, 116), Vector2(ox + 204 + shift, 40), 2.2, accent, 0.96)
	_draw_arc(image, Vector2(ox + 155, 86), 46.0 - float(frame) * 2.2, -0.15, PI * 0.96, 3.0, accent, 0.58)


func _draw_paper_accents(image: Image, frame: int, accent: Color, outline: Color) -> void:
	var ox := frame * FRAME_SIZE.x
	for index in range(4):
		var base_x := ox + 52 + index * 39 + frame * 4
		var base_y := 44 + ((index + frame) % 3) * 22
		_draw_line(image, Vector2(base_x, base_y + 54), Vector2(base_x + 54, base_y + 16), 3.6, outline, 0.66)
		_draw_line(image, Vector2(base_x, base_y + 52), Vector2(base_x + 54, base_y + 14), 1.5, accent, 1.0)
		_draw_rect(image, Rect2(Vector2(base_x + 42, base_y + 8), Vector2(9, 6)), accent, 0.86)


func _draw_lantern_accents(image: Image, frame: int, accent: Color, outline: Color) -> void:
	var ox := frame * FRAME_SIZE.x
	var center := Vector2(ox + 142, 76)
	var radius := 35.0 + sin(float(frame) * 0.72) * 5.0
	_draw_arc(image, center, radius + 4.0, 0.10 + frame * 0.20, PI * 1.82 + frame * 0.20, 5.0, outline, 0.48)
	_draw_arc(image, center, radius, 0.10 + frame * 0.20, PI * 1.82 + frame * 0.20, 2.2, accent, 0.92)
	_draw_circle(image, center + Vector2(cos(frame * 0.62) * radius, sin(frame * 0.62) * radius * 0.56), 5.5, accent, 0.96)


func _draw_line(image: Image, start: Vector2, end: Vector2, width: float, color: Color, alpha: float) -> void:
	var min_x: int = maxi(0, int(floor(min(start.x, end.x) - width - 2.0)))
	var max_x: int = mini(image.get_width() - 1, int(ceil(max(start.x, end.x) + width + 2.0)))
	var min_y: int = maxi(0, int(floor(min(start.y, end.y) - width - 2.0)))
	var max_y: int = mini(image.get_height() - 1, int(ceil(max(start.y, end.y) + width + 2.0)))
	var segment := end - start
	var length_squared: float = max(segment.length_squared(), 0.001)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var point := Vector2(x + 0.5, y + 0.5)
			var t: float = clamp((point - start).dot(segment) / length_squared, 0.0, 1.0)
			var closest := start + segment * t
			var distance := point.distance_to(closest)
			if distance <= width:
				var local_alpha: float = alpha * clamp(1.0 - distance / width, 0.0, 1.0)
				_blend_pixel(image, x, y, color, local_alpha)


func _draw_arc(image: Image, center: Vector2, radius: float, start_angle: float, end_angle: float, width: float, color: Color, alpha: float) -> void:
	var steps := 32
	var previous := center + Vector2(cos(start_angle), sin(start_angle)) * radius
	for step in range(1, steps + 1):
		var t: float = float(step) / float(steps)
		var angle: float = lerp(start_angle, end_angle, t)
		var current := center + Vector2(cos(angle), sin(angle) * 0.58) * radius
		_draw_line(image, previous, current, width, color, alpha)
		previous = current


func _draw_circle(image: Image, center: Vector2, radius: float, color: Color, alpha: float) -> void:
	var min_x: int = maxi(0, int(floor(center.x - radius)))
	var max_x: int = mini(image.get_width() - 1, int(ceil(center.x + radius)))
	var min_y: int = maxi(0, int(floor(center.y - radius)))
	var max_y: int = mini(image.get_height() - 1, int(ceil(center.y + radius)))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var distance := Vector2(x + 0.5, y + 0.5).distance_to(center)
			if distance <= radius:
				_blend_pixel(image, x, y, color, alpha * clamp(1.0 - distance / radius, 0.0, 1.0))


func _draw_rect(image: Image, rect: Rect2, color: Color, alpha: float) -> void:
	var min_x: int = maxi(0, int(floor(rect.position.x)))
	var max_x: int = mini(image.get_width() - 1, int(ceil(rect.position.x + rect.size.x)))
	var min_y: int = maxi(0, int(floor(rect.position.y)))
	var max_y: int = mini(image.get_height() - 1, int(ceil(rect.position.y + rect.size.y)))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			_blend_pixel(image, x, y, color, alpha)


func _blend_pixel(image: Image, x: int, y: int, color: Color, alpha: float) -> void:
	var base: Color = image.get_pixel(x, y)
	var local_alpha: float = clamp(alpha, 0.0, 1.0)
	var out_alpha: float = clamp(base.a + local_alpha * (1.0 - base.a), 0.0, 1.0)
	var out_color := Color(
		lerp(base.r, color.r, local_alpha),
		lerp(base.g, color.g, local_alpha),
		lerp(base.b, color.b, local_alpha),
		out_alpha
	)
	image.set_pixel(x, y, out_color)


func _neighbor_alpha(image: Image, x: int, y: int, width: int, height: int) -> float:
	var max_alpha: float = 0.0
	for yy in range(maxi(0, y - 2), mini(height, y + 3)):
		for xx in range(maxi(0, x - 2), mini(width, x + 3)):
			max_alpha = max(max_alpha, image.get_pixel(xx, yy).a)
	return max_alpha
