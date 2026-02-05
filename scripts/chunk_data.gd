extends Resource
class_name ChunkData

@export var chunk_pos: Vector2i
@export var terrain_data: PackedFloat32Array

# get the vertex value of the vertex at position 'pos' in the terrain_data array
func get_vertex_value(pos: Vector2i) -> float:
	if pos.x > Globals.CHUNK_SIZE or pos.y > Globals.CHUNK_SIZE:
		push_error("Position", pos, "out of bounds")
	return terrain_data[pos.x + pos.y * (Globals.CHUNK_SIZE + 1)]
