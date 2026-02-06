extends Control

@export var player: Player

func _ready() -> void:
	$Inventory.initialize(player.inventory_data)
