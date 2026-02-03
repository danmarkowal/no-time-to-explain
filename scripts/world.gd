extends Node
class_name World

@export var player: Node2D
@export var terrain_generator: TerrainGenerator
@export var world_bounds: Rect2i

func _ready() -> void:
	var min = world_bounds.position
	var max = min + world_bounds.size
	for y in range(min.y, max.y):
		for x in range(min.x, max.x):
			terrain_generator.generate_chunk(Vector2i(x, y))
		
	
func _process(delta: float) -> void:
	# load chunks around the player
	for y in [-1, 0, 1]:
		for x in [-1, 0 ,1]:
			var chunk_pos = self.player.chunk_pos + Vector2i(x, y)
			if world_bounds.has_point(chunk_pos):
				terrain_generator.ensure_loaded(chunk_pos)
