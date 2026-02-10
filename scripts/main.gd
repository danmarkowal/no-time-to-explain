extends Node2D


func initialize(_inventory_data: InventoryData) -> void:
	$Diver.inventory_manager.inventory_data = _inventory_data


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PhysicsServer2D.area_set_param(
		get_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY,
		9.80665
	)
