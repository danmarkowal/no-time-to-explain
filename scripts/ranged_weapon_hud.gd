extends Control


@export var item: RangedWeapon


func _ready() -> void:
	item.on_shoot.connect(refresh_ammo)
	item.on_reload.connect(refresh_ammo)
	$WeaponNameText.text = item.name
	refresh_ammo()
	

func refresh_ammo() -> void:
	$AmmoText.text = item.get_ammo_text()
