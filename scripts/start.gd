extends Node2D
class_name Start


@onready var diving_suit_item = preload("res://resources/item/items/diving_suit_item.tres")


func escape():
	if can_escape_safely():
		print("Escaping submarine")
	else:
		print("Cannot escape safely")


func can_escape_safely() -> bool:
	# the player needs to be holding a diving suit to progress to the main area
	# alternatively they can drop it in the escape pod and have one extra inventory space
	var has_diving_suit = $Player.inventory_manager.has_item(diving_suit_item) \
		or $Submarine.is_diving_suit_in_pod()
	return $Submarine.is_player_in_pod() and has_diving_suit
