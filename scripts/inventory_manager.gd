extends Node2D
class_name InventoryManager

@onready var dropped_item_prefab = preload("res://scenes/dropped_item.tscn")

@export var player: Node2D
@export var inventory_data: InventoryData
@export var item_slot: Node2D


func _ready() -> void:
	inventory_data.on_slot_selected.connect(func (x): refresh_held_item())
	inventory_data.on_item_dropped.connect(func (x): refresh_held_item())
	refresh_held_item()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_item"):
		drop_current_item()
	for i in 5:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			if inventory_data.selected_slot != i:
				inventory_data.selected_slot = i
			else:
				inventory_data.selected_slot = -1
			break


func refresh_held_item() -> void:
	var slot = inventory_data.current_slot
	unequip()
	if slot == null or slot.is_empty():
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

	
func drop_current_item() -> void:
	var current_slot = inventory_data.current_slot
	if current_slot.is_empty():
		return
	var dropped_item = dropped_item_prefab.instantiate()
	dropped_item.item = current_slot.item_data
	# decreases count
	inventory_data.drop_item()
	player.drop_item(dropped_item)
