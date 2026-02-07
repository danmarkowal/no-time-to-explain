extends CharacterBody2D

@export var speed: float = 2.0 * Globals.PPM

@export var inventory_data: InventoryData


func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() - $Components/Head.global_position
	# 1 = right
	# -1 = left
	var direction = sign(mouse_pos.dot(Vector2.RIGHT))
	
	$Components.scale.x = direction
	$Components/Head.rotation = clamp(-direction * mouse_pos.angle_to(direction * Vector2.RIGHT), -PI / 6, PI / 6)


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("walk_left", "walk_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
