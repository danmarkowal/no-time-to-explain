extends Button

var slot_data: SlotData
var selected: bool = false


func set_slot_data(_slot_data: SlotData) -> void:
	slot_data = _slot_data
	if selected:
		theme_type_variation = "SelectedButton"
		
	if slot_data.item_data == null:
		return
		
	var item_data = slot_data.item_data
	$MarginContainer/TextureRect.texture = item_data.texture
	tooltip_text = "%s" % [item_data.name]
	
	if slot_data.quantity > 1:
		$QuantityLabel.text = "x%s" % slot_data.quantity
		$QuantityLabel.show()


func _pressed() -> void:
	slot_data.on_clicked.emit()
