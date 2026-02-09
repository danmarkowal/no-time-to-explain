extends Control
class_name GUI


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("close_screen") and get_child_count() > 0:
		get_children()[get_child_count() - 1].queue_free()


func push_screen(screen: Control):
	add_child(screen)
