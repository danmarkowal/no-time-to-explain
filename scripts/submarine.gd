extends Node2D
class_name Submarine


@onready var diving_suit_item = preload("res://resources/item/items/diving_suit_item.tres")

@export var start: Start


func _ready() -> void:
	$EscapeButton.start = start
	

func is_diving_suit_in_pod() -> bool:
	for body in $EscapePodArea.get_overlapping_bodies():
		if body is DroppedItem and body.item == diving_suit_item:
			return true
	return false


func is_player_in_pod() -> bool:
	for body in $EscapePodArea.get_overlapping_bodies():
		if body is Player:
			return true
	return false
	
