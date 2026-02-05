extends Node2D
class_name ChunkInstance

var chunk_data: ChunkData
var isovalue: float

const CORNERS := [
	Vector2(0.0, 0.0), # 0 top-left
	Vector2(1.0, 0.0), # 1 top-right
	Vector2(1.0, 1.0), # 2 bottom-right
	Vector2(0.0, 1.0)  # 3 bottom-left
]

const EDGE_CORNERS := [
	[0, 1], # top
	[1, 2], # right
	[2, 3], # bottom
	[3, 0]  # left
]

const MS_POLYGONS := [
	[],                             # 0  - no corners inside
	[4, 0, 7],                      # 1  - TL
	[5, 1, 4],                      # 2  - TR
	[7, 0, 1, 5],                   # 3  - TL+TR (top)
	[5, 2, 6],                      # 4  - BR
	# 5  - TL + BR (diagonal) -> produce two separate triangles (TL & BR)
	[4, 0, 7, 5, 2, 6],
	[4, 1, 2, 6],                   # 6  - TR+BR (right)
	[7, 0, 1, 2, 6],                # 7  - TL+TR+BR (top+right)
	[7, 3, 6],                      # 8  - BL
	[4, 6, 3, 0, 7],                # 9  - TL+BL (left)
	# 10 - TR + BL (diagonal) -> two separate triangles (TR & BL)
	[5, 1, 4, 7, 3, 6],
	[0, 1, 5, 6, 3],                # 11 - TL+TR+BL (top+left)
	[5, 2, 3, 7],                   # 12 - BR+BL (bottom)
	[4, 0, 3, 2, 5],                # 13 - TL+BR+BL (left+bottom)
	[4, 1, 2, 3, 7],                # 14 - TR+BR+BL (right+bottom)
	[0, 1, 2, 3]                    # 15 - all inside (full cell)
]

const MS_TRIANGLES := [
	[],                                     # 0
	[[0, 1, 2]],                            # 1
	[[0, 1, 2]],                            # 2
	[[0, 1, 2], [0, 2, 3]],                 # 3
	[[0, 1, 2]],                            # 4
	# 5 (diagonal) -> two triangles: [4,0,7] and [5,2,6]
	[[0, 1, 2], [3, 4, 5]],
	[[0, 1, 2], [0, 2, 3]],                 # 6
	[[0, 1, 2], [0, 2, 3], [0, 3, 4]],      # 7
	[[0, 1, 2]],                            # 8
	[[0, 1, 2], [0, 2, 3], [0, 3, 4]],      # 9  (5 vertices -> fan)
	# 10 (diagonal) -> two triangles: [5,1,4] and [7,3,6]
	[[0, 1, 2], [3, 4, 5]],
	[[0, 1, 2], [0, 2, 3], [0, 3, 4]],      # 11
	[[0, 1, 2], [0, 2, 3]],                 # 12
	[[0, 1, 2], [0, 2, 3], [0, 3, 4]],      # 13
	[[0, 1, 2], [0, 2, 3], [0, 3, 4]],      # 14
	[[0, 1, 2], [0, 2, 3]]                  # 15
]

class Cell:
	var verts: Array[Vector2]
	var indices: Array[int]

func build(_isovalue: float):
	self.isovalue = _isovalue
	
	var verts: Array[Vector2] = []
	var indices: Array[int] = []
	var base_index = 0
	
	for y in range(Globals.CHUNK_SIZE):
		for x in range(Globals.CHUNK_SIZE):
			var cell = build_cell(Vector2i(x, y), _isovalue)
			verts.append_array(cell.verts)
			indices.append_array(cell.indices.map(func(i): return i + base_index))
			base_index += cell.verts.size()
	
	if verts.size() == 0:
		return
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector2Array(verts)
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(indices)
	
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	$ChunkBody/ChunkMesh.mesh = mesh

func is_close(a: float, b: float) -> bool:
	return abs(a - b) <= 0.01
	
func is_inside(x: float, _isovalue: float) -> bool:
	return x <= _isovalue

func safe_interp_t(a_val: float, b_val: float, _isovalue: float) -> float:
	var denom = b_val - a_val
	if abs(denom) < 1e-9:
		return 0.5
	return clamp((_isovalue - a_val) / denom, 0.0, 1.0)

func build_cell(cell_pos: Vector2i, _isovalue: float) -> Cell:
	var verts: Array[Vector2] = []
	var indices: Array[int] = []
	
	var v: Array[float] = [self.chunk_data.get_vertex_value(cell_pos),
		self.chunk_data.get_vertex_value(cell_pos + Vector2i(1, 0)),
		self.chunk_data.get_vertex_value(cell_pos + Vector2i(1, 1)),
		self.chunk_data.get_vertex_value(cell_pos + Vector2i(0, 1))]
	#var center = (v[0] + v[1] + v[2] + v[3]) / 4.0
	
	var casevalue = int(is_inside(v[0], _isovalue)) \
		| int(is_inside(v[1], _isovalue)) << 1 \
		| int(is_inside(v[2], _isovalue)) << 2 \
		| int(is_inside(v[3], _isovalue)) << 3
	var vertex_ptrs = MS_POLYGONS[casevalue]
	for ptr in vertex_ptrs:
		var offset: Vector2
		# corner
		if ptr <= 3:
			offset = CORNERS[ptr]
		# edge
		else:
			# 0 - top
			# 1 - right
			# 2 - bottom
			# 3 - left
			var edge_index = ptr - 4
			var edge_values = [v[edge_index], v[(edge_index + 1) % v.size()]]
			var t = safe_interp_t(edge_values[0], edge_values[1], _isovalue)
			var edge_verts = EDGE_CORNERS[edge_index].map(func(i): return CORNERS[i])
			offset = lerp(edge_verts[0], edge_verts[1], t)
		verts.append((Vector2(cell_pos) + offset) * Globals.TILE_SIZE * Globals.PPM)
	
	for triangle in MS_TRIANGLES[casevalue]:
		indices.append_array(triangle)

	var cell = Cell.new()
	cell.verts = verts
	cell.indices = indices
	return cell

func draw_chunk_grid():
	# grid
	var rand = rand_from_seed(hash(self.chunk_data.chunk_pos))[0]
	var grid_color = Color.from_hsv((rand % 255) / 255.0, 1.0, 1.0)
	for i in range(Globals.CHUNK_SIZE):
		draw_line(Vector2(i * Globals.TILE_SIZE * Globals.PPM, 0.0),
			Vector2(i * Globals.TILE_SIZE * Globals.PPM, Globals.CHUNK_SIZE * Globals.TILE_SIZE * Globals.PPM),
			grid_color)
		draw_line(Vector2(0.0, i * Globals.TILE_SIZE * Globals.PPM),
			Vector2(Globals.CHUNK_SIZE * Globals.TILE_SIZE * Globals.PPM, i * Globals.TILE_SIZE * Globals.PPM),
			grid_color)
	# values
	for y in range(Globals.CHUNK_SIZE + 1):
		for x in range(Globals.CHUNK_SIZE + 1):
			var t = self.chunk_data.get_vertex_value(Vector2i(x, y))
			var inside_color = Color.GREEN if is_inside(t, self.isovalue) else Color.RED
			var center_pos = Vector2(x, y) * Globals.TILE_SIZE * Globals.PPM
			draw_circle(center_pos, 8.0, inside_color)
			var value_color = Color.BLACK.lerp(Color.WHITE, t)
			draw_circle(center_pos, 7.0, value_color)
			
			var directions = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
			var delta = Vector2.ZERO
			var valid_count = 0
			for direction in directions:
				var pos = Vector2i(x, y) + direction
				if Rect2i(0, 0, Globals.CHUNK_SIZE, Globals.CHUNK_SIZE).has_point(pos):
					var sample = self.chunk_data.get_vertex_value(pos)
					delta += Vector2(direction) * (sample - t)
					valid_count += 1
			delta /= valid_count
			
			draw_line(center_pos, center_pos + delta * 64.0, Color.BLUE)

func _draw() -> void:
	draw_chunk_grid()
	queue_redraw()
