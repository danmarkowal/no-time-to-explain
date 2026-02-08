extends Node2D
class_name InteractionManager

@onready var safe_screen_prefab = preload("res://scenes/safe_code_screen.tscn")

@export var player: Node2D
@export var interaction_distance: float = 1.5

var gui: GUI

## target_pos must be an absolute position
func can_interact_with(node: Node2D) -> bool:
	var origin = global_position
	var target_pos = node.global_position
	if origin.distance_squared_to(target_pos) > (interaction_distance * Globals.PPM) ** 2:
		return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target_pos)
	query.collision_mask = 1 << 2 # Layer 4
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	return result.is_empty()

func interact_with(node: Node2D) -> void:
	if not can_interact_with(node):
		return
	if node is DroppedItem:
		if player.inventory_manager.pickup_item(node.item):
			node.queue_free()
	if node is Safe:
		var safe_screen = safe_screen_prefab.instantiate()
		safe_screen.safe = node
		gui.push_screen(safe_screen)
