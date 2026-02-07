extends StaticBody2D


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("climb_down"):
		$CollisionShape2D.disabled = true
	else:
		$CollisionShape2D.disabled = false
