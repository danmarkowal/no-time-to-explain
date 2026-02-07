@tool
extends NinePatchRect
class_name Ladder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shape = RectangleShape2D.new()
	shape.size = size
	$Area2D/CollisionShape2D.shape = shape
	$Area2D/CollisionShape2D.position = size / 2
