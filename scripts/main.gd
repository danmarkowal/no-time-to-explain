extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PhysicsServer2D.area_set_param(
		get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY,
		9.80665
	)
