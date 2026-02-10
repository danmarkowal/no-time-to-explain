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


func can_shoot() -> bool:
	return ammo > 0


func shoot() -> void:
	ammo = max(ammo - 1, 0)


func reload() -> void:
	ammo = mag_size
