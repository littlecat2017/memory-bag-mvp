extends SceneTree

const MainScene := preload("res://scenes/main.tscn")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main: Control = MainScene.instantiate()
	get_root().add_child(main)
	main.set_anchors_preset(Control.PRESET_FULL_RECT)
	main.size = Vector2(1280, 720)
	await _settle(8)

	_verify_quick_bar_exists(main)
	_verify_slot_reorder(main)
	_verify_trash_discard(main)
	_verify_pending_to_empty_slot(main)
	_verify_pending_replaces_slot(main)
	_verify_pending_requires_core_confirmation(main)

	main.queue_free()
	await process_frame
	print("verify_quick_bag_interaction: ok")
	quit(0)


func _verify_quick_bar_exists(main: Control) -> void:
	_expect(main.quick_bag_bar != null, "quick bag bar should exist")
	_expect(main.trash_zone_card != null, "trash zone should exist")
	_expect(main.found_zone_card != null, "found zone should exist")
	_expect(main.quick_bag_slots.size() == 4, "quick bag should have 4 visible MVP slots")
	_expect(abs(main.quick_bag_bar.anchor_top - 0.690) < 0.001, "quick bag should sit in the lower operation area")
	_expect(abs(main.quick_bag_bar.anchor_bottom - 0.965) < 0.001, "quick bag should be a large backpack tray")


func _verify_slot_reorder(main: Control) -> void:
	_set_bag(main, [
		"mem_mothers_soup",
		"mem_wooden_sword",
		"mem_reason_to_depart",
		"mem_my_name",
	])
	main._on_memory_card_dropped({
		"memory_id": "mem_mothers_soup",
		"source_kind": "bag",
		"source_index": 0,
	}, "bag", 2)
	_expect(main.game_state.owned_memory_ids[0] == "mem_reason_to_depart", "slot 0 should receive swapped memory")
	_expect(main.game_state.owned_memory_ids[2] == "mem_mothers_soup", "slot 2 should receive dragged memory")


func _verify_trash_discard(main: Control) -> void:
	_set_bag(main, [
		"mem_mothers_soup",
		"mem_wooden_sword",
		"mem_reason_to_depart",
	])
	main._on_memory_card_dropped({
		"memory_id": "mem_mothers_soup",
		"source_kind": "bag",
		"source_index": 0,
	}, "trash", -1)
	_expect(not main.game_state.has_memory("mem_mothers_soup"), "trash drop should remove non-core memory")
	_expect(main.game_state.has_discarded("mem_mothers_soup"), "trash drop should mark non-core memory discarded")
	_expect(not main.game_state.world_feedback_history.is_empty(), "trash drop should record feedback")


func _verify_pending_to_empty_slot(main: Control) -> void:
	_set_bag(main, [
		"mem_wooden_sword",
		"mem_reason_to_depart",
		"mem_my_name",
	])
	main.game_state.begin_memory_replacement("mem_someone_waits")
	main._update_bag_cards()
	main._on_memory_card_dropped({
		"memory_id": "mem_someone_waits",
		"source_kind": "found",
		"source_index": -1,
	}, "bag", 3)
	_expect(main.game_state.has_memory("mem_someone_waits"), "pending memory should be gained from found zone")
	_expect(not main.game_state.has_pending_memory(), "pending memory should clear after empty-slot gain")
	_expect(main.game_state.owned_memory_ids.size() == 4, "empty-slot gain should fill bag to capacity")


func _verify_pending_replaces_slot(main: Control) -> void:
	_set_bag(main, [
		"mem_mothers_soup",
		"mem_wooden_sword",
		"mem_reason_to_depart",
		"mem_my_name",
	])
	main.game_state.begin_memory_replacement("mem_someone_waits")
	main._update_bag_cards()
	main._on_memory_card_dropped({
		"memory_id": "mem_someone_waits",
		"source_kind": "found",
		"source_index": -1,
	}, "bag", 0)
	_expect(main.game_state.has_memory("mem_someone_waits"), "pending memory should replace occupied target slot")
	_expect(main.game_state.has_discarded("mem_mothers_soup"), "occupied target should be discarded")
	_expect(main.game_state.owned_memory_ids.size() == 4, "replacement should keep bag within capacity")
	_expect(not main.game_state.has_pending_memory(), "pending memory should clear after replacement")


func _verify_pending_requires_core_confirmation(main: Control) -> void:
	_set_bag(main, [
		"mem_mothers_soup",
		"mem_wooden_sword",
		"mem_reason_to_depart",
		"mem_my_name",
	])
	main.game_state.begin_memory_replacement("mem_someone_waits")
	main._update_bag_cards()
	main._on_memory_card_dropped({
		"memory_id": "mem_someone_waits",
		"source_kind": "found",
		"source_index": -1,
	}, "bag", 2)
	_expect(main.game_state.has_pending_memory(), "pending memory should wait before replacing core memory")
	_expect(main.game_state.has_memory("mem_reason_to_depart"), "core target should not be discarded before confirmation")
	_expect(not main.game_state.has_memory("mem_someone_waits"), "pending memory should not be owned before core confirmation")
	_expect(main.pending_core_discard_id == "mem_reason_to_depart", "core replacement should set pending confirmation id")
	_expect(main.replacement_confirm_box.visible, "core replacement should show confirmation UI")
	main._on_confirm_core_discard_pressed()
	_expect(main.game_state.has_memory("mem_someone_waits"), "confirmed core replacement should gain pending memory")
	_expect(main.game_state.has_discarded("mem_reason_to_depart"), "confirmed core replacement should discard core memory")
	_expect(not main.game_state.has_pending_memory(), "confirmed core replacement should clear pending memory")


func _set_bag(main: Control, memory_ids: Array[String]) -> void:
	main.game_state.owned_memory_ids = memory_ids.duplicate()
	main.game_state.discarded_memory_ids.clear()
	main.game_state.pending_memory_id = ""
	main.game_state.world_feedback_history.clear()
	main.replacement_panel.visible = false
	main.replacement_confirm_box.visible = false
	main.pending_core_discard_id = ""
	main._update_bag_cards()


func _settle(frames: int) -> void:
	for _index in range(frames):
		await process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_fail(message)


func _fail(message: String) -> void:
	push_error("verify_quick_bag_interaction: %s" % message)
	quit(1)
