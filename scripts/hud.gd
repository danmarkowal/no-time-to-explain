extends Control

# this needs to be a node 2d since player can be Player or Diver
@export var player: Node2D

func _ready() -> void:
	$Inventory.initialize(player.inventory_data)
