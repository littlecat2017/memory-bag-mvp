extends SceneTree

const MainScene := preload("res://scenes/main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	await _settle()
	var expected_titles := {
		"mvp_named_with_reason": "结局：名字与理由仍在",
		"mvp_named_without_reason": "结局：名字仍在，理由失落",
		"mvp_nameless_with_reason": "结局：无名者仍记得理由",
		"mvp_nameless_without_reason": "结局：没有名字，也没有来处",
	}
	for ending_id in expected_titles.keys():
		main._on_debug_force_ending_pressed(str(ending_id))
		await _settle()
		main._on_next_pressed()
		await _settle()
		main._on_next_pressed()
		await _settle()
		if main.ending_summary_layer == null or not main.ending_summary_layer.visible:
			main.queue_free()
			_fail("ending summary should be visible for %s" % ending_id)
			return
		if main.ending_summary_title_label.text != expected_titles[ending_id]:
			main.queue_free()
			_fail("ending summary title mismatch for %s: %s" % [
				ending_id,
				main.ending_summary_title_label.text,
			])
			return
		if main.ending_summary_bag_label.text.find("保留的记忆：") != 0:
			main.queue_free()
			_fail("ending summary should include kept memory list")
			return
		if main.ending_summary_lost_label.text.find("丢失的记忆：") != 0:
			main.queue_free()
			_fail("ending summary should include lost memory list")
			return
	main.queue_free()
	await process_frame
	print("verify_ending_summary_ui: ok")
	quit(0)


func _settle() -> void:
	for _index in range(3):
		await process_frame


func _fail(message: String) -> void:
	push_error("verify_ending_summary_ui: %s" % message)
	quit(1)
