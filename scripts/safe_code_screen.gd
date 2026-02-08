extends Control
class_name SafeCodeScreen

var safe: Safe


func _ready() -> void:
	$Panel/CodeTextEdit.max_length = str(safe.code).length()


func _on_close_button_pressed() -> void:
	queue_free()


func _on_done_button_pressed() -> void:
	pass # Replace with function body.
