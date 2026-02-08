extends Resource
class_name InventoryData

@export var slot_datas: Array[SlotData] :
	set(value):
		for i in value.size():
			var slot = value[i]
			if not slot.is_valid():
				push_error("Invalid slot %d" % [i])
		slot_datas = value

var selected_slot: int = -1 :
	get():
		return selected_slot
	set(value):
		if value < -1 or value >= slot_datas.size():
			push_error("Selected slot out of range")
		selected_slot = value
		on_slot_selected.emit(value)

var current_item: ItemData :
	get():
		if selected_slot == -1:
			return null
		return slot_datas[selected_slot].item_data

signal on_item_added(slot: SlotData)
signal on_slot_selected(slot_index: int)

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
