extends CharacterBody2D
class_name Player

var chunk_pos: Vector2i = Vector2i.ZERO
@export var speed: float = 200.0
@export var inventory_data: InventoryData
@onready var shape_cast_2d: ShapeCast2D = $Camera2D/ShapeCast2D

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

	# Check if pressed Tab or E for inventory or chest
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	
	if Input.is_action_just_pressed("interact"):
		interact()

# if either of rays collides with a chest, you can interact with it
func interact() -> void:
	if shape_cast_2d.is_colliding():
		shape_cast_2d.get_collider(0).player_interact()
