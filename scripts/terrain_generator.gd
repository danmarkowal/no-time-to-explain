extends Node
class_name TerrainGenerator

@onready var chunk_prefab = preload("res://scenes/chunk_instance.tscn")

@export var noise: FastNoiseLite
@export var isovalue: float
@export var player: Player
@export var world_bounds: Rect2i
var chunks: Dictionary = {} # Vector2i -> ChunkData
var loaded_chunks: Dictionary = {} # Vector2i -> ChunkInstance

func _ready() -> void:
	noise.seed = randi()

func ensure_loaded(chunk_pos: Vector2i):
	if not is_loaded(chunk_pos):
		load_chunk(chunk_pos)

# loads a chunk at a given chunk position
# generates the chunk if not generated already
# loading a chunk means generating a mesh from the chunk data and instantiating the mesh
func load_chunk(chunk_pos: Vector2i):
	var chunk_data: ChunkData = chunks.get(chunk_pos) # may be null
	if chunk_data == null:
		chunk_data = self.generate_chunk(chunk_pos)
	var chunk_instance = chunk_prefab.instantiate()
	chunk_instance.position = chunk_pos * Globals.CHUNK_SIZE * Globals.TILE_SIZE * Globals.PPM
	chunk_instance.chunk_data = chunk_data
	chunk_instance.build(self.isovalue)
	self.loaded_chunks.set(chunk_pos, chunk_instance)
	get_tree().root.add_child.call_deferred(chunk_instance)

# generates chunk data using simplex noise
func generate_chunk(chunk_pos: Vector2i) -> ChunkData:
	var terrain_data = PackedFloat32Array()
	var chunk_origin = chunk_pos * Globals.CHUNK_SIZE * Globals.TILE_SIZE
	# store chunk data in rows
	# + 1 because we want Globals.CHUNK_SIZE cells (bars and stars)
	for y in range(Globals.CHUNK_SIZE + 1):
		for x in range(Globals.CHUNK_SIZE + 1):
			var sample_pos = Vector2(chunk_origin + Vector2i(x, y) * Globals.TILE_SIZE)
			var sample = self.noise.get_noise_2dv(sample_pos)
			terrain_data.append(sample)
	var chunk_data = ChunkData.new()
	chunk_data.chunk_pos = chunk_pos
	chunk_data.terrain_data = terrain_data
	self.chunks.set(chunk_pos, chunk_data)
	return chunk_data

func is_loaded(chunk_pos: Vector2i) -> bool:
	return self.loaded_chunks.has(chunk_pos)

# if the chunk at the given position is loaded, the chunk will be unloaded
# this means that the chunk instance (mesh, colliders etc.) is deleted
# throws an error if the chunk is not loaded
func unload_chunk(chunk_pos: Vector2i):
	var chunk_instance = self.loaded_chunks.get(chunk_pos)
	if chunk_instance == null:
		push_error("Tried to unload a chunk that wasn't loaded")
	chunk_instance.queue_free()
	self.loaded_chunks.erase(chunk_pos)

# deletes the chunk from the chunk cache and unloads it if necessary
func delete_chunk(chunk_pos: Vector2i):
	if is_loaded(chunk_pos):
		unload_chunk(chunk_pos)
	self.chunks.erase(chunk_pos)
