extends Node2D


@export var start: Start


func _ready() -> void:
	$EscapeButton.start = start
