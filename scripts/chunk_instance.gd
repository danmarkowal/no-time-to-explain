extends Node2D
class_name ChunkInstance

const chest_prefab = preload("res://scenes/chest.tscn")
const oxygen_geyser_prefab = preload("res://scenes/oxygen_geyser.tscn")

@export var debug_render: bool = false
@export var min_chests: int = 0
@export var max_chests: int = 3
@export var min_geysers: int = 1
@export var max_geysers: int = 3

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
	
	create_collision_from_mesh(verts, indices)
	
	spawn_chests()
	spawn_geysers()

func spawn_chests() -> void:
	var spawn_locations = get_spawn_locations()
	spawn_locations.shuffle()
	var n_chests = randi_range(min_chests, max_chests)
	for i in min(n_chests, spawn_locations.size()):
		var location = spawn_locations[i]
		var chest = chest_prefab.instantiate()
		chest.position = location["pos"]
		chest.rotation = location["normal"].angle() + PI / 2
		add_child(chest)
		
func spawn_geysers() -> void:
	var spawn_locations = get_spawn_locations()
	spawn_locations.shuffle()
	var n_chests = randi_range(min_geysers, max_geysers)
	for i in min(n_chests, spawn_locations.size()):
		var location = spawn_locations[i]
		var geyser = oxygen_geyser_prefab.instantiate()
		geyser.position = location["pos"]
		geyser.rotation = location["normal"].angle() + PI / 2
		add_child(geyser)

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
	if debug_render:
		draw_chunk_grid()

# --- Add/replace these functions in your ChunkInstance.gd ---

func create_collision_from_mesh(verts: Array, indices: Array) -> void:
	"""
	Build Collision objects for every connected component in the triangle mesh.
	verts: Array[Vector2] - vertex positions (one per vertex)
	indices: Array[int] - triangle indices (flat array: i0,i1,i2, i0,i1,i2, ...)
	"""
	# remove old collision children
	for child in $ChunkBody.get_children():
		if child is CollisionPolygon2D or child is CollisionShape2D:
			child.queue_free()

	if verts.is_empty() or indices.is_empty():
		return

	# 1) Deduplicate vertices (quantize to tol) and remap indices
	var merge = _merge_vertices(verts, 1e-3)
	var u_verts: Array = merge.unique_vertices
	var remap: Array = merge.remap_indices

	# remap triangles
	var tris: Array = []
	for i in range(0, indices.size(), 3):
		var a = remap[indices[i + 0]]
		var b = remap[indices[i + 1]]
		var c = remap[indices[i + 2]]
		# skip degenerate triangles
		if a == b or b == c or c == a:
			continue
		tris.append([a, b, c])

	# 2) Find connected components of triangles (by shared edge)
	var components = _find_triangle_components(tris)

	# 3) For each component build colliders
	for comp in components:
		# comp is Array of triangle indices into tris
		var comp_tris = []
		var vertex_used := {}
		for ti in comp:
			var tri = tris[ti]
			comp_tris.append(tri.duplicate())
			for v in tri:
				vertex_used[v] = true

		# build local vertex list and local remap to keep arrays small
		var local_index_map := {}
		var local_vertices := []
		var next_local = 0
		for v in vertex_used.keys():
			local_index_map[v] = next_local
			local_vertices.append(u_verts[v])
			next_local += 1
		# remap comp_tris to local indices
		var local_tris := []
		for tri in comp_tris:
			local_tris.append([local_index_map[tri[0]], local_index_map[tri[1]], local_index_map[tri[2]]])

		# try to extract boundary loops for this component
		var edge_map := {}
		for tri in local_tris:
			_add_edge_to_map(edge_map, tri[0], tri[1])
			_add_edge_to_map(edge_map, tri[1], tri[2])
			_add_edge_to_map(edge_map, tri[2], tri[0])

		# collect boundary directed adjacency (edges that appear exactly once)
		var adjacency := {}
		for key in edge_map.keys():
			var info = edge_map[key]
			if info.count == 1:
				# we stored one directed dir in info.dirs[0]
				var dir_pair = info.dirs[0]
				var from = dir_pair[0]; var to = dir_pair[1]
				if not adjacency.has(from):
					adjacency[from] = []
				adjacency[from].append(to)

		var loops = _trace_loops_from_adjacency(adjacency)

		# If we have exactly one loop and it covers the component boundary, create CollisionPolygon2D.
		# If multiple loops (likely holes) or no loops, fallback to concave segments.
		if loops.size() == 1:
			var loop = loops[0]
			# convert local indices in loop -> world points
			var poly_points := []
			for li in loop:
				poly_points.append(local_vertices[li])
			# simplify collinear points
			poly_points = _simplify_collinear(poly_points, 1e-3)
			# need at least 3 points
			if poly_points.size() >= 3:
				var cp = CollisionPolygon2D.new()
				cp.polygon = PackedVector2Array(poly_points)
				cp.build_mode = CollisionPolygon2D.BUILD_SOLIDS
				$ChunkBody.add_child(cp)
				continue # next component

		# fallback: build ConcavePolygonShape2D from component triangles (guaranteed correct for static geometry)
		_make_concave_collision_from_local_tris(local_vertices, local_tris)


# ----------------- Helpers -----------------

func _merge_vertices(verts: Array, tol: float = 1e-3) -> Dictionary:
	# Returns {"unique_vertices": Array, "remap_indices": Array}
	var map := {}
	var unique := []
	var remap := []
	for i in range(verts.size()):
		var p: Vector2 = verts[i]
		var key = str(int(round(p.x / tol))) + "_" + str(int(round(p.y / tol)))
		if not map.has(key):
			map[key] = unique.size()
			unique.append(p)
		remap.append(map[key])
	return {"unique_vertices": unique, "remap_indices": remap}

func _add_edge_to_map(edge_map: Dictionary, a: int, b: int) -> void:
	# undirected key groups the same edge; we still store the directed occurrence for boundary tracing
	var key = str(min(a,b)) + "_" + str(max(a,b))
	if not edge_map.has(key):
		edge_map[key] = {"count": 0, "dirs": []}
	edge_map[key].count += 1
	edge_map[key].dirs.append([a, b])

func _find_triangle_components(tris: Array) -> Array:
	"""
	Build adjacency between triangles when they share any edge; return list of components,
	each component is an Array of triangle indices (into tris).
	"""
	var edge_to_tris := {}
	for ti in range(tris.size()):
		var t = tris[ti]
		var edges = [
			[str(min(t[0],t[1])) + "_" + str(max(t[0],t[1])), ti],
			[str(min(t[1],t[2])) + "_" + str(max(t[1],t[2])), ti],
			[str(min(t[2],t[0])) + "_" + str(max(t[2],t[0])), ti]
		]
		for e in edges:
			var key = e[0]
			if not edge_to_tris.has(key):
				edge_to_tris[key] = []
			edge_to_tris[key].append(ti)

	# build triangle adjacency (by shared edge)
	var tri_adj := []
	tri_adj.resize(tris.size())
	for key in edge_to_tris.keys():
		var tri_list = edge_to_tris[key]
		for i in range(tri_list.size()):
			for j in range(i + 1, tri_list.size()):
				var a = tri_list[i]; var b = tri_list[j]
				if not tri_adj[a]:
					tri_adj[a] = []
				if not tri_adj[b]:
					tri_adj[b] = []
				tri_adj[a].append(b)
				tri_adj[b].append(a)

	# BFS to find components
	var visited := []
	visited.resize(tris.size())
	for i in range(visited.size()):
		visited[i] = false

	var components := []
	for i in range(tris.size()):
		if visited[i]:
			continue
		# new component
		var comp := []
		var q = [i]
		visited[i] = true
		while not q.is_empty():
			var cur = q.pop_front()
			comp.append(cur)
			if tri_adj[cur]:
				for nb in tri_adj[cur]:
					if not visited[nb]:
						visited[nb] = true
						q.push_back(nb)
		components.append(comp)
	return components

func _trace_loops_from_adjacency(adjacency: Dictionary) -> Array:
	"""
	adjacency: from_idx -> [to_idx, ...] (directed boundary edges).
	Returns an Array of loops, each loop is Array of vertex indices in order.
	"""
	var used_edges := {}
	var loops := []
	# attempt to start from every adjacency entry
	for start in adjacency.keys():
		for next_candidate in adjacency[start]:
			var edge_key = str(start) + "_" + str(next_candidate)
			if used_edges.has(edge_key):
				continue
			# follow directed edges to build a loop
			var loop := []
			var cur = start
			var next = next_candidate
			# mark the starting directed edge used
			used_edges[edge_key] = true
			loop.append(cur)
			cur = next
			var safety = 0
			while true:
				safety += 1
				if safety > adjacency.size() * 4:
					# abort if something is weird
					loop = []
					break
				# add cur to loop
				loop.append(cur)
				# if loop closed
				if cur == start:
					# remove the duplicate final element (we want each vertex once)
					loop.pop_back()
					break
				# find next outgoing unused edge from cur
				var found = false
				if adjacency.has(cur):
					for nxt in adjacency[cur]:
						var k = str(cur) + "_" + str(nxt)
						if not used_edges.has(k):
							used_edges[k] = true
							cur = nxt
							found = true
							break
				if not found:
					# open chain -> fail
					loop = []
					break
			if loop.size() > 0:
				# ensure loop has >= 3 unique vertices (Godot doesn't have to_set())
				var seen := {}
				for v in loop:
					seen[v] = true
				var unique_count = seen.keys().size()
				if unique_count >= 3:
					loops.append(loop)
	# optionally: sort loops by length descending
	loops.sort_custom(_sort_loops_by_length)
	return loops


func _sort_loops_by_length(a, b):
	return b.size() - a.size() # descending

func _simplify_collinear(points: Array, eps: float = 1e-3) -> Array:
	if points.size() <= 3:
		return points.duplicate()
	var out := []
	for i in range(points.size()):
		var prev = points[(i - 1 + points.size()) % points.size()]
		var cur = points[i]
		var nxt = points[(i + 1) % points.size()]
		var v1 = (cur - prev)
		var v2 = (nxt - cur)
		# if either segment is tiny, keep the vertex (to avoid division/normalize artifacts)
		if v1.length() < eps or v2.length() < eps:
			out.append(cur)
			continue
		var v1n = v1.normalized()
		var v2n = v2.normalized()
		# if directions nearly equal or opposite (collinear) -> drop the middle point
		if v1n.distance_to(v2n) < eps:
			continue
		out.append(cur)
	if out.size() < 3:
		return points.duplicate()
	return out

func _make_concave_collision_from_local_tris(local_vertices: Array, local_tris: Array) -> void:
	# Build segments for concave shape: each triangle contributes 3 segments (start,end)
	var segments := PackedVector2Array()
	for tri in local_tris:
		var A = local_vertices[tri[0]]
		var B = local_vertices[tri[1]]
		var C = local_vertices[tri[2]]
		segments.append(A); segments.append(B)
		segments.append(B); segments.append(C)
		segments.append(C); segments.append(A)
	var conc = ConcavePolygonShape2D.new()
	conc.segments = segments
	var shape_node = CollisionShape2D.new()
	shape_node.shape = conc
	$ChunkBody.add_child(shape_node)

# safe sample of scalar at integer grid coords clamped to valid range
func _sample_vertex(ix: int, iy: int) -> float:
	var max_index = Globals.CHUNK_SIZE # vertex coords run 0..CHUNK_SIZE inclusive
	ix = clamp(ix, 0, max_index)
	iy = clamp(iy, 0, max_index)
	return self.chunk_data.get_vertex_value(Vector2i(ix, iy))

# returns Array of Dictionaries: { "pos": Vector2, "normal": Vector2 }
# min_above_neighbors: require at least this many of the 8 neighbours to be > isovalue
# max_tilt_degrees: maximum tilt from perfectly upward allowed (in degrees)
func get_spawn_locations(min_above_neighbors: int = 5, max_tilt_degrees: float = 75.0) -> Array:
	var results := []
	var seen := {} # dedupe by quantized position key
	var up_vec := Vector2(0.0, -1.0) # Godot Y grows down, so "up" is negative Y
	var max_cos := cos(deg_to_rad(max_tilt_degrees))
	var grid_spacing := Globals.TILE_SIZE * Globals.PPM
	var max_index := Globals.CHUNK_SIZE # vertex coords run 0..CHUNK_SIZE inclusive

	# iterate every cell, only consider cells that actually have a contour (case != 0 && != 15)
	for y in range(Globals.CHUNK_SIZE):
		for x in range(Globals.CHUNK_SIZE):
			var cell_pos = Vector2i(x, y)
			# replicate casevalue logic from build_cell
			var v := [
				self.chunk_data.get_vertex_value(cell_pos),
				self.chunk_data.get_vertex_value(cell_pos + Vector2i(1, 0)),
				self.chunk_data.get_vertex_value(cell_pos + Vector2i(1, 1)),
				self.chunk_data.get_vertex_value(cell_pos + Vector2i(0, 1))
			]
			var casevalue := int(is_inside(v[0], isovalue)) \
				| int(is_inside(v[1], isovalue)) << 1 \
				| int(is_inside(v[2], isovalue)) << 2 \
				| int(is_inside(v[3], isovalue)) << 3
			if casevalue == 0 or casevalue == 15:
				continue # no contour in this cell

			# get the exact contour verts for this cell (use your existing build_cell so interpolation is identical)
			var cell = build_cell(cell_pos, isovalue)
			for world_pos in cell.verts:
				# dedupe (quantize to avoid duplicates along shared cell edges)
				var qx = int(round(world_pos.x * 100.0)) # quantize to 0.01 world units
				var qy = int(round(world_pos.y * 100.0))
				var key = str(qx) + "_" + str(qy)
				if seen.has(key):
					continue
				seen[key] = true

				# map world position back into the sample/grid coordinate space (floating)
				var grid_pos = world_pos / grid_spacing
				var ix = int(round(grid_pos.x))
				var iy = int(round(grid_pos.y))

				# count the 8 neighbours (3x3 minus center) that are above the isovalue
				var above_count = 0
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						if dx == 0 and dy == 0:
							continue
						var s = _sample_vertex(ix + dx, iy + dy)
						# "above ground" is interpreted as value > isovalue
						if s > isovalue:
							above_count += 1

				if above_count < min_above_neighbors:
					continue

				# approximate gradient at nearest integer sample (central differences)
				var left  = _sample_vertex(ix - 1, iy)
				var right = _sample_vertex(ix + 1, iy)
				var up    = _sample_vertex(ix, iy - 1)
				var down  = _sample_vertex(ix, iy + 1)

				var dFdx := 0.0
				var dFdy := 0.0
				# prefer central differences where possible, fall back to forward/backward at borders
				if ix - 1 >= 0 and ix + 1 <= max_index:
					dFdx = (right - left) * 0.5
				elif ix + 1 <= max_index:
					dFdx = (right - _sample_vertex(ix, iy))
				elif ix - 1 >= 0:
					dFdx = (_sample_vertex(ix, iy) - left)

				if iy - 1 >= 0 and iy + 1 <= max_index:
					dFdy = (down - up) * 0.5
				elif iy + 1 <= max_index:
					dFdy = (down - _sample_vertex(ix, iy))
				elif iy - 1 >= 0:
					dFdy = (_sample_vertex(ix, iy) - up)

				var grad = Vector2(dFdx, dFdy)
				if grad.length_squared() < 1e-8:
					# very flat / undefined normal -> skip
					continue
				var normal = grad.normalized() # gradient is normal to the level set

				# require the normal to face generally upwards (compare with up_vec)
				# note: since up_vec is (0,-1), larger dot means closer to upward direction
				if normal.dot(up_vec) < max_cos:
					continue

				# candidate accepted
				results.append({"pos": world_pos, "normal": normal})

	return results
