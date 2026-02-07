extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var texture: Texture2D
@export var stack_size: int = 1
@export var prefab: PackedScene


func default_instance() -> Node2D:
	var root = Sprite2D.new()
	root.texture = texture
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return root
