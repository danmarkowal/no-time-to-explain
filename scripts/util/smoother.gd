class_name Smoother

var value: float

func _init(initial_value: float) -> void:
	self.value = initial_value

func update(delta: float, increasing: bool):
	if increasing:
		value = clamp(value + delta, 0.0, 1.0)
	else:
		value = clamp(value - delta, 0.0, 1.0)

func smooth(start: float, end: float) -> float:
	return lerp(start, end, value)
