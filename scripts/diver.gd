extends CharacterBody2D
class_name Diver

@export var speed: float = 2.0 * Globals.PPM
@export var swim_anim_range: float = PI / 6
@export var swim_anim_speed_legs: float = 1.0
@export var swim_anim_speed_arms: float = 0.5
@export var swim_anim_phase_offset_legs: float = PI / 2
@export var swim_anim_phase_offset_arms: float = PI / 6
@export var swim_anim_speed_moving_multiplier = 2.0
@export var particle_emitters: Array[CPUParticles2D]

@export var inventory_manager: InventoryManager
@export var interaction_manager: InteractionManager
@export var gui: GUI
@export_group("Survival Stats")
@export var max_health: float = 100.0
@export var max_oxygen: float = 100.0
@export var oxygen_drain_rate: float = 2.0 
@export var drown_damage_rate: float = 10.0 

var chunk_pos: Vector2i = Vector2i.ZERO
var swim_anim_t_legs = 0.0
var swim_anim_t_arms = 0.0
var speed_smoother = Smoother.new(0.0)
var torso_smoother = LerpSmoother.new(0.0)

func _ready() -> void:
	interaction_manager.gui = gui

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position() - $Components/Head.global_position
	# 1 = righ    t
	# -1 = left
	var direction = sign(mouse_pos.dot(Vector2.RIGHT))
	if direction == 0:
		direction = 1
	
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
	
	if velocity.length_squared() > 0:
		for emitter in particle_emitters:
			emitter.initial_velocity_max = 128.0
	else:
		for emitter in particle_emitters:
			emitter.initial_velocity_max = 32.0
	
	var current_item = inventory_manager.inventory_data.current_item
	if current_item is RangedWeapon:
		aim(direction)
	else:
		$Components/Torso/RightArm.rotation = sin(2.0 * PI * swim_anim_t_arms - swim_anim_phase_offset_arms) * swim_anim_range

func aim(direction: int) -> void:
	var delta = get_global_mouse_position() - $Components/Torso/RightArm.global_position
	$Components/Torso/RightArm.global_rotation = -(delta.angle_to(Vector2.RIGHT) + direction * PI / 2)

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
	handle_survival_stats(delta)

func handle_survival_stats(delta: float) -> void:
	# 1. Drain Oxygen
	# If you want it to always drain, just do this:
	self.oxygen -= oxygen_drain_rate * delta
	
	if oxygen <= 0:
		self.health -= drown_damage_rate * delta
		
	if health <= 0:
		die()

func die():
	print("Diver has perished.")
func interact_with(node: Node2D):
	interaction_manager.interact_with(node)

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
