extends Control
class_name HUD

# this needs to be a node 2d since player can be Player or Diver
@export var player: Node2D

@export var inventory: Inventory
@export var health_bar: ProgressBar
@export var oxygen_bar: ProgressBar
@export var item_hud: Control

func _ready() -> void:
	inventory.initialize(player.inventory_manager.inventory_data)
	health_bar.value = 100
	oxygen_bar.value = 100

func _on_player_health_changed(new_health):
	health_bar.value = new_health

func _on_player_oxygen_changed(new_oxygen):
	oxygen_bar.value = new_oxygen
