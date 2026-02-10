extends Control
class_name DeathScreen


@export var death_message: String


func _ready() -> void:
	$DeathMessage.text = death_message


func _on_try_again_button_pressed() -> void:
	$ColorRect2.show()
	$ColorRect2/AnimationPlayer.play("fade_in")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/start.tscn")
