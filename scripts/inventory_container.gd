extends Area2D
class_name InventoryContainer

const inventory_screen_prefab = preload("res://scenes/inventory_screen.tscn")

@export var inventory_data: InventoryData


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		get_tree().call_group("player", "interact_with", self)


func interaction_success(interaction_manager: InteractionManager) -> void:
	var inventory_screen = inventory_screen_prefab.instantiate()
	inventory_screen.receiver = interaction_manager.player.inventory_manager.inventory_data
	inventory_screen.initialize(inventory_data)
	interaction_manager.gui.push_screen(inventory_screen)
