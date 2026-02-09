extends Control


@export var title: RichTextLabel

var receiver: InventoryData


func initialize(_title: String, inventory_data: InventoryData) -> void:
	title.text = _title
	inventory_data.on_slot_clicked.connect(func (slot): inventory_data.try_move_item(slot, receiver))
	$Inventory.initialize(inventory_data)


func _on_close_button_pressed() -> void:
	queue_free()
