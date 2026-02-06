extends CharacterBody2D
class_name Player

@export var speed: float = 2.0 * Globals.PPM
@export var swim_anim_range: float = PI / 6
@export var swim_anim_speed_legs: float = 1.0
@export var swim_anim_speed_arms: float = 0.5
@export var swim_anim_phase_offset_legs: float = PI / 2
@export var swim_anim_phase_offset_arms: float = PI / 6
@export var swim_anim_speed_moving_multiplier = 2.0

@export var inventory_data: InventoryData

var chunk_pos: Vector2i = Vector2i.ZERO
var swim_anim_t_legs = 0.0
var swim_anim_t_arms = 0.0
var speed_smoother = Smoother.new(0.0)
var torso_smoother = LerpSmoother.new(0.0)

func _unhandled_input(event: InputEvent) -> void:
	for i in 5:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			inventory_data.selected_slot = i

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() - $Components/Head.global_position
	# 1 = right
	# -1 = left
	var direction = sign(mouse_pos.dot(Vector2.RIGHT))
	
	# update swim animiation speed
	speed_smoother.update(delta / 0.5, velocity.length_squared() > 0)
	
	# torso rotates in the direction opposite to which we are swimming
	var target_torso_rotation = 0.0
	if velocity.x < 0:
		target_torso_rotation = -direction * PI / 12
	elif velocity.x > 0:
		target_torso_rotation = direction * PI / 12
	elif velocity.y != 0:
		target_torso_rotation = PI / 12
	torso_smoother.update(target_torso_rotation, delta, 1.0)
	
	$Components.scale.x = direction
	# this is an ugly mess because when we set the scale to one everything turns upside down
	$Components/Head.rotation = clamp(-direction * mouse_pos.angle_to(direction * Vector2.RIGHT), -PI / 6, PI / 6)
	$Components/Torso.rotation = torso_smoother.value
	
	# swim animation
	var anim_speed_legs = speed_smoother.smooth(swim_anim_speed_legs, swim_anim_speed_legs * swim_anim_speed_moving_multiplier)
	var anim_speed_arms = speed_smoother.smooth(swim_anim_speed_arms, swim_anim_speed_arms * swim_anim_speed_moving_multiplier)
	
	swim_anim_t_legs += delta * anim_speed_legs
	swim_anim_t_arms += delta * anim_speed_arms
	
	$Components/Torso/LeftLeg.rotation = sin(2.0 * PI * swim_anim_t_legs) * swim_anim_range
	$Components/Torso/RightLeg.rotation = sin(2.0 * PI * swim_anim_t_legs - swim_anim_phase_offset_legs) * swim_anim_range
	
	$Components/Torso/LeftArm.rotation = sin(2.0 * PI * swim_anim_t_arms) * swim_anim_range
	$Components/Torso/RightArm.rotation = sin(2.0 * PI * swim_anim_t_arms - swim_anim_phase_offset_arms) * swim_anim_range

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
