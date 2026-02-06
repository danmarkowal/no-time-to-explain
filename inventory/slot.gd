extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

var selected: bool = false

func set_slot_data(slot_data: SlotData) -> void:
	if selected:
		var style = get_theme_stylebox("panel").duplicate()
		style.bg_color = Color(0.2, 0.2, 0.2, 1.0)
		style.border_color = Color(0.4, 0.4, 0.4, 1.0)
		style.set_border_width_all(1)
		add_theme_stylebox_override("panel", style)
		
	if slot_data.item_data == null:
		return
		
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.texture
	tooltip_text = "%s" % [item_data.name]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
