extends Control
class_name SafeCodeScreen

var safe: Safe


signal on_opened()


func _ready() -> void:
	$Panel/CodeTextEdit.max_length = str(safe.code).length()


func _on_close_button_pressed() -> void:
	queue_free()


func _on_done_button_pressed() -> void:
	done()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		done()


func close() -> void:
	queue_free()
	
	
func done() -> void:
	if $Panel/CodeTextEdit.text == safe.code:
		safe.opened = true
		close()
	else:
		$Panel/CodeTextEdit.text = ""
		$Panel/DoneButton.theme_type_variation = "WrongButton"
