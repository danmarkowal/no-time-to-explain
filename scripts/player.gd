extends CharacterBody2D

@export var speed: float = 2.0 * Globals.PPM
@export var run_multiplier: float = 1.5
@export var walk_anim_phase_offset_arms: float = PI
@export var walk_anim_range_arms: float = PI / 6
@export var walk_anim_phase_offset_legs: float = PI
@export var walk_anim_range_legs: float = PI / 24
@export var walk_anim_exp: float = 0.6

@export var inventory_data: InventoryData

var walk_anim_t_legs = 0.0
var walk_anim_t_arms = 0.0
var left_arm_smoother = LerpSmoother.new(0.0)
var right_arm_smoother = LerpSmoother.new(0.0)
var left_leg_smoother = LerpSmoother.new(0.0)
var right_leg_smoother = LerpSmoother.new(0.0)


func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() - $Components/Head.global_position
	# 1 = right
	# -1 = left
	var direction = sign(mouse_pos.dot(Vector2.RIGHT))
	
	$Components.scale.x = direction
	$Components/Head.rotation = clamp(-direction * mouse_pos.angle_to(direction * Vector2.RIGHT), -PI / 6, PI / 6)

	if velocity.x != 0:
		walk_anim_t_legs += delta
		walk_anim_t_arms += delta
		
		left_arm_smoother.update(sin_pow(TAU * walk_anim_t_arms - walk_anim_phase_offset_arms, walk_anim_exp) * walk_anim_range_arms, delta, 0.2)
		right_arm_smoother.update(sin_pow(TAU * walk_anim_t_arms, walk_anim_exp) * walk_anim_range_arms, delta, 0.2)
		left_leg_smoother.update(sin_pow(TAU * walk_anim_t_legs, walk_anim_exp) * walk_anim_range_legs, delta, 0.2)
		right_leg_smoother.update(sin_pow(TAU * walk_anim_t_legs - walk_anim_phase_offset_legs, walk_anim_exp) * walk_anim_range_legs, delta, 0.2)
	else:
		left_arm_smoother.update(0.0, delta, 0.2)
		right_arm_smoother.update(0.0, delta, 0.2)
		left_leg_smoother.update(0.0, delta, 0.2)
		right_leg_smoother.update(0.0, delta, 0.2)
	
	$Components/LeftArm.rotation = left_arm_smoother.value
	$Components/RightArm.rotation = right_arm_smoother.value
	$Components/LeftLeg.rotation = left_leg_smoother.value
	$Components/RightLeg.rotation = right_leg_smoother.value

func sin_pow(x: float, p: float):
	var y = sin(x)
	var s = sign(y)
	return s * pow(abs(y), p)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("walk_left", "walk_right")
	var speed_multiplier = run_multiplier if Input.is_action_pressed("run") else 1.0
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)
	move_and_slide()
