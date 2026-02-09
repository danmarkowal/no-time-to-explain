extends Control


var receiver: InventoryData


func initialize(inventory_data: InventoryData) -> void:
	inventory_data.on_slot_clicked.connect(func (slot): inventory_data.try_move_item(slot, receiver))
	$Inventory.initialize(inventory_data)
