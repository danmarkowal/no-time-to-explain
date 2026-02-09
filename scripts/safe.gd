extends Area2D
class_name Safe

@onready var safe_screen_prefab = preload("res://scenes/safe_code_screen.tscn")

@export var code: String
@export var opened: bool = false
@export var inventory_data: InventoryData


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		get_tree().call_group("player", "interact_with", self)


func interaction_success(interaction_manager: InteractionManager) -> void:
	if opened:
		# open safe inventory
		pass
	else:
		var safe_screen = safe_screen_prefab.instantiate()
		safe_screen.safe = self
		interaction_manager.gui.push_screen(safe_screen)
