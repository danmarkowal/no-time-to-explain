extends Resource
class_name InventoryData

@export var slot_datas: Array[SlotData] :
	set(value):
		for i in value.size():
			var slot = value[i]
			if slot == null or not slot.is_valid():
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

var current_slot: SlotData :
	get():
		if selected_slot == -1:
			return null
		return slot_datas[selected_slot]

var current_item: ItemData :
	get():
		if current_slot == null:
			return null
		return current_slot.item_data

signal on_item_moved()
signal on_item_added(slot: SlotData)
signal on_item_dropped(slot: SlotData)
signal on_slot_selected(slot_index: int)
signal on_slot_clicked(slot: SlotData)

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
	
func drop_item() -> bool:
	if current_slot == null:
		return false
	var res = current_slot.try_decrement(1)
	on_item_dropped.emit(current_slot)
	return res
	
func try_move_item(from: SlotData, to: InventoryData) -> bool:
	if from.is_empty():
		return false
	var item = from.item_data
	var res = from.try_decrement(1) and to.add_item(item)
	if res:
		on_item_moved.emit()
	return res
	
func has_item(item: ItemData) -> bool:
	for slot in slot_datas:
		if slot.item_matches(item):
			return true
	return false
	
func try_remove_item(item: ItemData) -> bool:
	for slot in slot_datas:
		if slot.item_matches(item):
			slot.clear()
			return true
	return false
		
