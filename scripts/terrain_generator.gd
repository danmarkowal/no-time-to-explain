extends Node
class_name TerrainGenerator

@onready var chunk_prefab = preload("res://scenes/chunk_instance.tscn")

@export var seed: int
@export var noise: FastNoiseLite
var chunks: Dictionary = {} # Vector2i -> ChunkData
var loaded_chunks: Dictionary = {} # Vector2i -> ChunkInstance

# loads a chunk at a given chunk position
# generates the chunk if not generated already
# loading a chunk means generating a mesh from the chunk data and instantiating the mesh
func load_chunk(chunk_pos: Vector2i):
	var chunk_data: ChunkData = chunks.get(chunk_pos) # may be null
	if chunk_data == null:
		chunk_data = self.generate_chunk(chunk_pos)
	var chunk_instance = chunk_prefab.instantiate()
	chunk_instance.chunk_data = chunk_data
	self.loaded_chunks.set(chunk_pos, chunk_instance)
	get_tree().root.add_child.call_deferred(chunk_instance)

# generates chunk data using simplex noise
func generate_chunk(chunk_pos: Vector2i) -> ChunkData:
	var terrain_data = PackedByteArray()
	var global_pos = Vector2(chunk_pos * Globals.CHUNK_SIZE)
	# store chunk data in rows
	for y in range(Globals.CHUNK_SIZE * Globals.CHUNK_RESOLUTION):
		for x in range(Globals.CHUNK_SIZE * Globals.CHUNK_RESOLUTION):
			self.noise.offset = Vector3(global_pos.x, global_pos.y, 0.0)
			var sample_pos = Vector2(x, y) / (Globals.CHUNK_RESOLUTION as float)
			var sample = self.noise.get_noise_2d(sample_pos.x, sample_pos.y)
			terrain_data.append(round(sample * 255.0))
	var chunk_data = ChunkData.new()
	chunk_data.chunk_pos = chunk_pos
	chunk_data.terrain_data = terrain_data
	self.chunks.set(chunk_pos, chunk_data)
	return chunk_data

# if the chunk at the given position is loaded, the chunk will be unloaded
# this means that the chunk instance (mesh, colliders etc.) is deleted
func unload_chunk(chunk_pos: Vector2i):
	var chunk_instance = loaded_chunks.get(chunk_pos)
	if chunk_instance == null:
		push_error("Tried to unload a chunk that wasn't loaded")
	chunk_instance.queue_free()
	loaded_chunks.erase(chunk_pos)
