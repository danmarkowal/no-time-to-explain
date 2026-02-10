extends ItemData
class_name RangedWeapon


@export var mag_size: int
@export var ammo: int = mag_size :
	set(value):
		if value < 0 or value > mag_size:
			push_error("Ammo out of range")
		ammo = value
@export var equip_sound: AudioStream
@export var unequip_sound: AudioStream
@export var shoot_sound: AudioStream


signal on_shoot()
signal on_reload()


func can_shoot() -> bool:
	return ammo > 0


func shoot() -> void:
	ammo = max(ammo - 1, 0)
	on_shoot.emit()


func reload() -> void:
	ammo = mag_size
	on_reload.emit()
	

func get_ammo_text() -> String:
	return "%s/%s" % [ammo, mag_size]
