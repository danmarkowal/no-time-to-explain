extends CharacterBody2D
class_name Player

@export var walk_speed: float = 2.0 * Globals.PPM
@export var climb_speed: float = 3.0 * Globals.PPM
@export var run_multiplier: float = 1.5
@export var walk_anim_phase_offset_arms: float = PI
@export var walk_anim_range_arms: float = PI / 6
@export var walk_anim_phase_offset_legs: float = PI
@export var walk_anim_range_legs: float = PI / 24
@export var walk_anim_exp: float = 0.6
@export_group("Survival Stats")
@export var max_health: float = 100.0
@export var max_oxygen: float = 100.0
@export var oxygen_drain_rate: float = 2.0  
@export var drown_damage_rate: float = 10.0 
@export var inventory_manager: InventoryManager
@export var interaction_manager: InteractionManager
@export var gui: GUI

var walk_anim_t_legs = 0.0
var walk_anim_t_arms = 0.0
var left_arm_smoother = LerpSmoother.new(0.0)
var right_arm_smoother = LerpSmoother.new(0.0)
var left_leg_smoother = LerpSmoother.new(0.0)
var right_leg_smoother = LerpSmoother.new(0.0)
var can_climb_ladder = false
var is_climbing_ladder = false
signal health_changed(value)
signal oxygen_changed(value)

var health = 100:
	set(val):
		health = clamp(val, 0, 100)
		health_changed.emit(health) 

var oxygen = 100:
	set(val):
		oxygen = clamp(val, 0, 100)
		oxygen_changed.emit(oxygen) 


func _ready() -> void:
	interaction_manager.gui = gui


func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() - $Components/Head.global_position
	# 1 = right
	# -1 = left
	var direction = sign(mouse_pos.dot(Vector2.RIGHT))
	if direction == 0:
		direction = 1
	
	$Components.scale.x = direction
	$Components/Head.rotation = clamp(-direction * mouse_pos.angle_to(direction * Vector2.RIGHT), -PI / 6, PI / 6)

	if velocity.length_squared() > 0:
		walk_anim_t_legs += delta
		walk_anim_t_arms += delta
		
		var arm_offset = -PI / 2 if is_climbing_ladder else 0
		left_arm_smoother.update(sin_pow(TAU * walk_anim_t_arms - walk_anim_phase_offset_arms, walk_anim_exp) * walk_anim_range_arms + arm_offset, delta, 0.2)
		right_arm_smoother.update(sin_pow(TAU * walk_anim_t_arms, walk_anim_exp) * walk_anim_range_arms + arm_offset, delta, 0.2)
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
	var climb_dir = -Input.get_axis("climb_down", "climb_up")
	if not can_climb_ladder:
		is_climbing_ladder = false
	elif climb_dir != 0:
		is_climbing_ladder = true
	
	if not is_on_floor() and not is_climbing_ladder:
		velocity += get_gravity() * delta
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("walk_left", "walk_right")
	var speed_multiplier = run_multiplier if Input.is_action_pressed("run") else 1.0
	
	if direction:
		velocity.x = direction * walk_speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * speed_multiplier)
	
	if is_climbing_ladder:
		if climb_dir != 0:
			velocity.y = climb_dir * climb_speed * speed_multiplier
		else:
			velocity.y = move_toward(velocity.y, 0, climb_speed * speed_multiplier)
	
	if is_on_floor() and velocity.length_squared() > 0:
		if not $WalkingSound.playing:
			$WalkingSound.playing = true
	else:
		$WalkingSound.playing = false
	
	move_and_slide()
	handle_survival_stats(delta)

func handle_survival_stats(delta: float) -> void:
	
	self.oxygen -= oxygen_drain_rate * delta
	
	if oxygen <= 0:
		self.health -= drown_damage_rate * delta
		
	if health <= 0:
		die()

func die():
	print("Diver has perished.")

func interact_with(node: Node2D):
	interaction_manager.interact_with(node)
