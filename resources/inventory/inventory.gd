extends PanelContainer
class_name Inventory

const slot_prefab = preload("res://resources/inventory/slot.tscn")

var inventory_data: InventoryData

func initialize(_inventory_data: InventoryData) -> void:
	inventory_data = _inventory_data
	inventory_data.on_item_moved.connect.call(func (): refresh())
	inventory_data.on_item_added.connect.call(func (item): refresh())
	inventory_data.on_item_dropped.connect.call(func (item): refresh())
	inventory_data.on_slot_selected.connect.call(func (slot): refresh())
	
	for slot in inventory_data.slot_datas:
		slot.on_clicked.connect(func (): inventory_data.on_slot_clicked.emit(slot))
	
	refresh()

func refresh() -> void:
	for child in $MarginContainer/HBoxContainer.get_children():
		child.queue_free()
	for i in inventory_data.slot_datas.size():
		var slot_data = inventory_data.slot_datas[i]
		var slot = slot_prefab.instantiate()
		slot.selected = (i == inventory_data.selected_slot)
		$MarginContainer/HBoxContainer.add_child(slot)
		if slot_data:
			slot.set_slot_data(slot_data)
