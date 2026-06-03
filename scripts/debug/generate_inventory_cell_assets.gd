extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/ui"))
	_save_cell("res://assets/ui/ui_inventory_cell_unlocked.png", Color(0.83, 0.74, 0.56, 0.78), Color(0.54, 0.39, 0.22, 0.86), Color(0.96, 0.91, 0.76, 0.38))
	_save_cell("res://assets/ui/ui_inventory_cell_locked.png", Color(0.42, 0.41, 0.37, 0.58), Color(0.28, 0.27, 0.24, 0.74), Color(0.76, 0.74, 0.66, 0.18))
	print("generate_inventory_cell_assets: ok")
	quit(0)


func _save_cell(path: String, fill: Color, border: Color, highlight: Color) -> void:
	var image := Image.create(128, 128, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in range(128):
		for x in range(128):
			var edge: int = min(min(x, y), min(127 - x, 127 - y))
			var color := fill
			if edge < 3:
				color = border
			elif edge < 6:
				color = border.lerp(fill, 0.45)
			elif x > 12 and x < 116 and y > 12 and y < 116 and (x + y) % 19 == 0:
				color = highlight
			image.set_pixel(x, y, color)
	var error := image.save_png(path)
	if error != OK:
		push_error("failed to save %s: %s" % [path, error])
