extends RefCounted

signal progress_changed(chapter_id: String, progress: float, chapter_distance: float)
signal node_triggered(node: Dictionary)

var registry
var state
var chapter_id := ""
var progress := 0.0
var meters_per_second := 8.0
var is_running := false
var triggered_node_ids: Dictionary = {}


func setup(data_registry, game_state) -> void:
	registry = data_registry
	state = game_state
	meters_per_second = float(registry.balance.get("travel", {}).get("meters_per_second", meters_per_second))


func start_chapter(next_chapter_id: String) -> void:
	chapter_id = next_chapter_id
	progress = 0.0
	triggered_node_ids.clear()
	is_running = true
	progress_changed.emit(chapter_id, progress, _chapter_distance())
	_trigger_ready_nodes()


func pause() -> void:
	is_running = false


func resume() -> void:
	if not chapter_id.is_empty():
		is_running = true


func tick(delta: float) -> void:
	if not is_running or chapter_id.is_empty():
		return
	progress = min(progress + meters_per_second * delta, _chapter_distance())
	progress_changed.emit(chapter_id, progress, _chapter_distance())
	_trigger_ready_nodes()


func debug_jump_to(target_progress: float) -> void:
	progress = clamp(target_progress, 0.0, _chapter_distance())
	progress_changed.emit(chapter_id, progress, _chapter_distance())
	_trigger_ready_nodes()


func _trigger_ready_nodes() -> void:
	var chapter := _chapter_data()
	for node in chapter.get("nodes", []):
		if typeof(node) != TYPE_DICTIONARY:
			continue
		var node_id := str(node.get("node_id", ""))
		if node_id.is_empty() or triggered_node_ids.has(node_id):
			continue
		var node_progress := float(node.get("progress", 0.0))
		if progress < node_progress:
			continue
		if node.has("trigger_after_event_id") and not state.seen_event_ids.has(str(node.trigger_after_event_id)):
			continue
		triggered_node_ids[node_id] = true
		is_running = false
		node_triggered.emit(node)
		return


func _chapter_data() -> Dictionary:
	for chapter in registry.chapter_flow.get("chapters", []):
		if typeof(chapter) == TYPE_DICTIONARY and str(chapter.get("chapter_id", "")) == chapter_id:
			return chapter
	return {}


func _chapter_distance() -> float:
	return float(_chapter_data().get("distance", 0.0))
