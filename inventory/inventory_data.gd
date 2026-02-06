extends Resource
class_name InventoryData

@export var slot_datas: Array[SlotData]

signal on_item_added(slot: SlotData)

# returns whether the item was added or not
func add_item(item_data: ItemData) -> bool:
	var empty_slot: SlotData = null
	for slot in slot_datas:
		if slot.item_matches(item_data) and slot.try_increment(1):
			on_item_added.emit(slot)
			return true
		elif slot.is_empty() and empty_slot == null:
			empty_slot = slot
	if empty_slot != null:
		empty_slot.set_item(item_data)
		on_item_added.emit(empty_slot)
		return true
	return false
