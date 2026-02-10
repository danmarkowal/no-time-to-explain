extends Node2D
class_name InventoryManager

@onready var dropped_item_prefab = preload("res://scenes/dropped_item.tscn")
@onready var ranged_weapon_hud_prefab = preload("res://scenes/ranged_weapon_hud.tscn")


@export var player: Node2D
@export var inventory_data: InventoryData
@export var item_slot: Node2D
@export var can_use_items: bool


func _ready() -> void:
	inventory_data.on_item_added.connect(func (x): refresh_held_item())
	inventory_data.on_slot_selected.connect(func (x): refresh_held_item())
	inventory_data.on_item_dropped.connect(func (x): refresh_held_item())
	inventory_data.on_item_removed.connect(func (x): refresh_held_item())
	inventory_data.on_item_used.connect(func (x): refresh_held_item())
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
	if event.is_action_pressed("use_item") \
			and can_use_items \
			and inventory_data.current_item != null:
		use_item_in_slot(inventory_data.current_slot)


func use_item_in_slot(slot: SlotData):
	# not null
	var item = slot.item_data
	if item is RangedWeapon:
		if player.has_method("ranged_attack") \
				and not player.ranged_attack(item):
			return
	elif item is MeleeWeapon:
		if player.has_method("melee_attack") \
				and not player.melee_attack(item):
			return
	var item_instance = item_slot.get_child(0)
	if item_instance.has_method("use_item") \
			and item_instance.use_item(self) \
			and item.is_consumable:
		inventory_data.use_item()


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
	item_slot.add_child(item_instance)

	if item_instance.has_method("on_equip"):
		item_instance.on_equip(item)
		
	if item is RangedWeapon:
		var hud = ranged_weapon_hud_prefab.instantiate()
		hud.item = item
		player.hud.item_hud.add_child(hud)


func unequip() -> void:
	for child in item_slot.get_children():
		if child.has_method("on_unequip"):
			child.on_unequip()
		child.queue_free()
	for child in player.hud.item_hud.get_children():
		child.queue_free()

	
func drop_current_item() -> void:
	var current_slot = inventory_data.current_slot
	if current_slot == null or current_slot.is_empty():
		return
	var dropped_item = dropped_item_prefab.instantiate()
	dropped_item.item = current_slot.item_data
	dropped_item.global_position = global_position
	# decreases count
	inventory_data.drop_item()
	get_tree().root.add_child(dropped_item)
	

func pickup_item(item: ItemData) -> bool:
	return inventory_data.add_item(item)
	
	
func has_item(item: ItemData) -> bool:
	return inventory_data.has_item(item)
	
	
func try_remove_item(item: ItemData) -> bool:
	return inventory_data.try_remove_item(item)
