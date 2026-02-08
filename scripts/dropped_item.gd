extends RigidBody2D
class_name DroppedItem

@export var item: ItemData


func _ready() -> void:
	$Sprite2D.texture = item.texture
	$ItemNameLabel.text = item.name


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("interact"):
		get_tree().call_group("player", "interact_with", self)


func _on_mouse_entered() -> void:
	$ItemNameLabel.visible = true


func _on_mouse_exited() -> void:
	$ItemNameLabel.visible = false
