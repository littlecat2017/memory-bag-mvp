extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failed := false


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	print("verify_reboot_shell: start")
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)

	_expect(main.validation_errors.is_empty(), "no validation errors")
	_expect(main.loaded_event_count() >= 80, "loads MVP events from original source script")
	_expect(main.loaded_memory_count() == 8, "loads exactly 8 MVP memories")

	main.jump_to_event("T0001")
	_expect(main.dialogue_panel.visible, "dialogue event shows dialogue panel")
	_expect(not main.operation_tray.visible, "dialogue event hides operation tray")
	_expect(main.text_label.text.find("自动前进") >= 0, "dialogue text comes from original script")

	main.jump_to_event("F0010")
	_expect(main.operation_tray.visible, "travel/memory event shows operation tray")
	_expect(not main.dialogue_panel.visible, "travel/memory event hides dialogue panel")
	_expect(main.hero_box.get_global_rect().end.y <= main.operation_tray.get_global_rect().position.y, "travel hero stays above tray")

	main.jump_to_event("F0003")
	var hero_rect: Rect2 = main.hero_box.get_global_rect()
	var enemy_rect: Rect2 = main.enemy_box.get_global_rect()
	var tray_rect: Rect2 = main.operation_tray.get_global_rect()
	_expect(main.enemy_box.visible, "battle event shows enemy")
	_expect(hero_rect.get_center().x < enemy_rect.get_center().x, "battle hero is left of enemy")
	_expect(hero_rect.end.y <= tray_rect.position.y, "battle hero stays above tray")
	_expect(enemy_rect.end.y <= tray_rect.position.y, "battle enemy stays above tray")

	_expect(main.inventory_cells.size() == 28, "inventory shows full 7x4 grid")
	_expect(main.inventory_grid.columns == 7, "inventory uses 7 columns")

	main.queue_free()
	if failed:
		quit(1)
		return
	print("verify_reboot_shell: ok")
	quit(0)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("verify_reboot_shell: %s" % message)
