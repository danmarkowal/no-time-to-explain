extends Node2D
class_name InventoryManager

@export var inventory_data: InventoryData
@export var item_slot: Node2D


func _ready() -> void:
	inventory_data.on_slot_selected.connect(on_slot_selected)
	on_slot_selected(inventory_data.selected_slot)


func _unhandled_input(event: InputEvent) -> void:
	for i in 5:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			if inventory_data.selected_slot != i:
				inventory_data.selected_slot = i
			else:
				inventory_data.selected_slot = -1
			break


func on_slot_selected(slot_index: int) -> void:
	var slot = inventory_data.slot_datas[slot_index]
	unequip()
	if slot.is_empty():
		return
	try_equip(slot.item_data)


func try_equip(item: ItemData) -> void:
	var prefab = item.prefab
	var item_instance: Node
	if prefab == null:
		item_instance = item.default_instance()
	else:
		item_instance = prefab.instantiate()
	if item_instance.has_method("on_equip"):
		item_instance.on_equip(item)
	item_slot.add_child(item_instance)


func unequip() -> void:
	for child in item_slot.get_children():
		if child.has_method("on_unequip"):
			child.on_unequip()
		child.queue_free()
