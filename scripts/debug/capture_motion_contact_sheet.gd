extends SceneTree

const FRAME_DIR := "res://temp/motion_review"
const OUTPUT_PATH := "res://temp/motion_review/motion_contact_sheet.png"
const FRAME_PATTERN := "walk_battle_review_frames%08d.png"
const FRAME_SIZE := Vector2i(320, 180)
const COLUMNS := 4

const SAMPLES := [
	{"frame": 18, "label": "walk 0.6s"},
	{"frame": 42, "label": "walk 1.4s"},
	{"frame": 66, "label": "walk 2.2s"},
	{"frame": 102, "label": "walk 3.4s"},
	{"frame": 150, "label": "battle appear"},
	{"frame": 180, "label": "hero attack"},
	{"frame": 210, "label": "enemy hit"},
	{"frame": 252, "label": "battle settle"},
	{"frame": 330, "label": "boss appear"},
	{"frame": 366, "label": "boss attack"},
	{"frame": 420, "label": "boss hit"},
	{"frame": 492, "label": "boss settle"},
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var rows := int(ceil(float(SAMPLES.size()) / float(COLUMNS)))
	var sheet := Image.create(FRAME_SIZE.x * COLUMNS, FRAME_SIZE.y * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.04, 0.04, 0.04, 1.0))
	for index in range(SAMPLES.size()):
		var sample: Dictionary = SAMPLES[index]
		var frame := int(sample.get("frame", 0))
		var image := Image.new()
		var path := "%s/%s" % [FRAME_DIR, FRAME_PATTERN % frame]
		if image.load(path) != OK:
			push_error("missing frame: %s" % path)
			quit(1)
			return
		image.resize(FRAME_SIZE.x, FRAME_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var target := Vector2i((index % COLUMNS) * FRAME_SIZE.x, int(index / COLUMNS) * FRAME_SIZE.y)
		sheet.blit_rect(image, Rect2i(Vector2i.ZERO, FRAME_SIZE), target)
	sheet.save_png(OUTPUT_PATH)
	print("capture_motion_contact_sheet: ok")
	quit(0)
