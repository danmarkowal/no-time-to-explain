extends Node2D
class_name World

@export var player: Diver
@export var terrain_generator: TerrainGenerator
@export var world_bounds: Rect2i
@export var draw_chunk_grid: bool = false

func _ready() -> void:
	var min = world_bounds.position
	var max = min + world_bounds.size
	for y in range(min.y, max.y):
		for x in range(min.x, max.x):
			terrain_generator.generate_chunk(Vector2i(x, y))
	player.position = pick_spawn_pos()
			

func pick_spawn_pos() -> Vector2:
	var found = false
	while not found:
		var rand_chunk_x = randi_range(world_bounds.position.x, world_bounds.position.x + 1)
		var rand_chunk_y = randi_range(world_bounds.position.y, world_bounds.position.y + world_bounds.size.y - 1)
		var chunk_pos = Vector2i(rand_chunk_x, rand_chunk_y)
		var chunk = terrain_generator.chunks[chunk_pos]
		if chunk == null:
			push_error("Couldn't get chunk %s" % [chunk_pos])
		for y in range(1, Globals.CHUNK_SIZE - 1):
			for x in range(1, Globals.CHUNK_SIZE - 1):
				var cell_pos = Vector2i(x, y)
				if is_valid_spawn(chunk, cell_pos):
					return chunk.get_global_pos(cell_pos)
	return Vector2.ZERO


func is_valid_spawn(chunk: ChunkData, cell_pos: Vector2i) -> bool:
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			var check_pos = cell_pos + Vector2i(dx, dy)
			if chunk.get_vertex_value(check_pos) <= terrain_generator.isovalue:
				return false
	return true

	
func _process(delta: float) -> void:
	# load chunks around the player
	for y in [-1, 0, 1]:
		for x in [-1, 0 ,1]:
			var chunk_pos = self.player.chunk_pos + Vector2i(x, y)
			if world_bounds.has_point(chunk_pos):
				terrain_generator.ensure_loaded(chunk_pos)

func _draw() -> void:
	if not draw_chunk_grid:
		return
	for chunk in terrain_generator.loaded_chunks.values():
		chunk.draw_chunk_grid()
	queue_redraw()
