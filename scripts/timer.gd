extends Control


@export var time: float = 30.0
@export var complete: bool = false


signal on_complete()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TimerLabel.text = format_time_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if complete:
		return
	time = max(time - delta, 0.0)
	if time == 0.0:
		complete = true
		on_complete.emit()
	# animation
	var scale = 1.0 + 0.5 * abs(sin(PI * time))
	$TimerLabel.add_theme_font_size_override("normal_font_size", int(32 * scale))
	if time <= 15.0:
		$TimerLabel.add_theme_color_override("default_color", Globals.RED)
	$TimerLabel.text = format_time_text()
	
	
func format_time_text() -> String:
	return str(int(ceil(time)))
