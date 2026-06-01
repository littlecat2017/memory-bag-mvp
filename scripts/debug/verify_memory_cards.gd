extends SceneTree

const DataRegistryScript := preload("res://scripts/data/data_registry.gd")
const MemoryCardViewScript := preload("res://scripts/ui/memory_card_view.gd")


func _init() -> void:
	var registry = DataRegistryScript.new()
	if not registry.load_all():
		_fail("data validation failed: %s" % "; ".join(registry.validation_errors))
		return

	for memory_id in registry.memories.keys():
		var card = MemoryCardViewScript.new()
		card.set_memory(registry.memories[memory_id])
		if not card.has_required_memory_text():
			_fail("card missing required text for %s" % memory_id)
			return
		var relation_text: String = card.relation_label.text
		var obligation_text: String = card.obligation_label.text
		var loss_text: String = card.loss_hint_label.text
		if relation_text.ends_with(" / ") or obligation_text == "承诺：" or loss_text == "丢弃提示：":
			card.free()
			_fail("card has empty relation fields for %s" % memory_id)
			return
		card.free()

	print("verify_memory_cards: ok; checked=%d" % registry.memories.size())
	quit(0)


func _fail(message: String) -> void:
	push_error("verify_memory_cards: %s" % message)
	quit(1)
