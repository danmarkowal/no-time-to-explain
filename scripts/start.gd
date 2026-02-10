extends Node2D
class_name Start


@onready var diving_suit_item = preload("res://resources/item/items/diving_suit_item.tres")
@onready var main_scene = preload("res://scenes/main.tscn")
@onready var death_screen_prefab = preload("res://scenes/death_screen.tscn")

@export var timer: CountdownTimer


func _ready() -> void:
	timer.on_complete.connect(escape)


func escape():
	if can_escape_safely():
		var main = main_scene.instantiate()
		$Player.inventory_manager.try_remove_item(diving_suit_item)
		main.initialize($Player.inventory_manager.inventory_data)
		get_tree().change_scene_to_node(main)
	else:
		var death_screen = death_screen_prefab.instantiate()
		death_screen.death_message = "You couldn't survive the pressure..."
		get_tree().change_scene_to_node(death_screen)


func can_escape_safely() -> bool:
	# the player needs to be holding a diving suit to progress to the main area
	# alternatively they can drop it in the escape pod and have one extra inventory space
	var has_diving_suit = $Player.inventory_manager.has_item(diving_suit_item) \
		or $Submarine.is_diving_suit_in_pod()
	return $Submarine.is_player_in_pod() and has_diving_suit
