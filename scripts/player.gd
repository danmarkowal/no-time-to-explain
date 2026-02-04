extends CharacterBody2D
class_name Player

var chunk_pos: Vector2i = Vector2i.ZERO
@export var speed: float = 200.0
@export var inventory_data: InventoryData

signal toggle_inventory()

func _process(delta: float) -> void:
	if velocity.x > 0:
		$Components.scale.x = 1
	elif velocity.x < 0:
		$Components.scale.x = -1

func _physics_process(delta: float) -> void:
	# Get input direction
	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("swim_right") - Input.get_action_strength("swim_left")
	direction.y = Input.get_action_strength("swim_down") - Input.get_action_strength("swim_up")
	direction = direction.normalized()

	# Apply movement
	velocity = direction * speed
	move_and_slide()

	# Update chunk position
	chunk_pos = floor(position / (Globals.CHUNK_SIZE * Globals.TILE_SIZE * Globals.PPM))

	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
