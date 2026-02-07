extends RigidBody2D

@export var item: ItemData


func _ready() -> void:
	$Sprite2D.texture = item.texture
