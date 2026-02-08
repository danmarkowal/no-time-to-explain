extends Area2D
class_name Safe

@export var code: int


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		get_tree().call_group("player", "interact_with", self)
