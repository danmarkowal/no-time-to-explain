extends PanelContainer
class_name Inventory

@onready var slot_prefab = preload("res://inventory/slot.tscn")

var inventory_data: InventoryData

func initialize(_inventory_data: InventoryData) -> void:
	inventory_data = _inventory_data
	inventory_data.on_item_added.connect.call(func (item): refresh())
	refresh()

func refresh() -> void:
	for child in $MarginContainer/HBoxContainer.get_children():
		child.queue_free()
	for slot_data in inventory_data.slot_datas:
		var slot = slot_prefab.instantiate()
		$MarginContainer/HBoxContainer.add_child(slot)
		if slot_data:
			slot.set_slot_data(slot_data)
