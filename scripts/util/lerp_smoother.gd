class_name LerpSmoother

var value: float

func _init(initial_value: float) -> void:
	self.value = initial_value
	
func update(target_value: float, delta: float, t: float, p: float = 0.01) -> void:
	value = target_value + (value - target_value) * pow(p, delta / t)
