extends Area2D


@export var start: Start


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		get_tree().call_group("player", "interact_with", self)
	

func interaction_success(interaction_manager: InteractionManager) -> void:
	start.escape()
