extends Area2D
class_name Safe

@onready var inventory_screen_prefab = preload("res://scenes/inventory_screen.tscn")
@onready var safe_screen_prefab = preload("res://scenes/safe_code_screen.tscn")

@export var code: String
@export var opened: bool = false
@export var inventory_data: InventoryData


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		get_tree().call_group("player", "interact_with", self)


func interaction_success(interaction_manager: InteractionManager) -> void:
	if opened:
		open_inventory(interaction_manager)
	else:
		var safe_screen = safe_screen_prefab.instantiate()
		safe_screen.on_opened.connect(func (): open_inventory(interaction_manager))
		safe_screen.safe = self
		interaction_manager.gui.push_screen(safe_screen)


func open_inventory(interaction_manager: InteractionManager) -> void:
	var inventory_screen = inventory_screen_prefab.instantiate()
	inventory_screen.receiver = interaction_manager.player.inventory_manager.inventory_data
	inventory_screen.initialize("Safe", inventory_data)
	interaction_manager.gui.push_screen(inventory_screen)
