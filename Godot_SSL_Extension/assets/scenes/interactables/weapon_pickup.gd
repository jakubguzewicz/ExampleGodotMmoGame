class_name WeaponPickup
extends Interactable

@onready var weapon:Weapon = $Weapon: set = _set_weapon

func _set_weapon(value:Weapon):
	miniature.texture = value.get_node(^"Weapon").texture
	value.visible = false
	weapon = value
	
func pickup(character:CharacterBody2D):
	#(void)character
	pass
