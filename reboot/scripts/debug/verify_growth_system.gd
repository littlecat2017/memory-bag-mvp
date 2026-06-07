extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("verify_growth_system: start")
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	await process_frame

	_expect(main.player_level == 1, "starts at level 1")
	_expect(int(main.player_equipment.get("weapon", "")) == 0 or str(main.player_equipment.get("weapon", "")) == "training_sword", "starts with training sword")

	var start_stats: Dictionary = main._growth_stats()
	main.player_attribute_points = 2
	main._spend_attribute_point("strength")
	main._spend_attribute_point("vitality")
	var grown_stats: Dictionary = main._growth_stats()
	_expect(int(grown_stats.get("attack", 0)) > int(start_stats.get("attack", 0)), "strength raises attack")
	_expect(int(grown_stats.get("max_hp", 0)) > int(start_stats.get("max_hp", 0)), "vitality raises max hp")
	_expect(main.player_attribute_points == 0, "spending points consumes points")

	main._set_pending_equipment("iron_leaf_blade")
	_expect(main.pending_equipment_id == "iron_leaf_blade", "pending equipment is stored")
	main._accept_pending_equipment()
	_expect(str(main.player_equipment.get("weapon", "")) == "iron_leaf_blade", "accepted weapon replaces weapon slot")
	_expect(main.pending_equipment_id == "", "accepted equipment clears pending state")

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_growth_system: ok")
	quit(0)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_growth_system: %s" % message)
