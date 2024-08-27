extends CharacterBody2D

signal interact(character:CharacterBody2D)

@onready var sprite_2d := $Sprite2D
@onready var weapon:Weapon = $Weapon
@onready var equipment:Equipment = $Equipment

@export var health := 100.0
@export var gold := 0

@export var INTERACT_RANGE = 100.0

var character_id := 0

var selected_interactable:Interactable

func _ready():
	pass
	
func attack():
	if is_instance_valid(weapon):
		weapon.attack()

func animate_walking():
	if is_instance_valid(weapon):
		weapon.animate_walking()
	
func animate_idle():
	if is_instance_valid(weapon):
		weapon.animate_idle()
		
func pickup_weapon(weapon_pickup:WeaponPickup):
	var new_weapon = weapon_pickup.weapon
	new_weapon.visible = true
	weapon_pickup.remove_child(new_weapon)
	## Determine slot for the weapon
	var new_item_index = -1
	if equipment.equipment_array[equipment.selected_item].animation_prefix == "empty":
		new_item_index = equipment.selected_item
	else:
		# Find the first empty slot
		for index in equipment.equipment_array.size():
			if equipment.equipment_array[index].animation_prefix == "empty":
				new_item_index = index
				break
		# We didn't find any empty slot
		if new_item_index == -1:
			new_item_index = equipment.selected_item
	## Replace the item and change to it
	equipment.replace_item(new_item_index, new_weapon)
	change_weapon(equipment.change_selected_item(new_item_index))
	
func drop_selected_item():
	equipment.drop_item(equipment.selected_item)
	change_weapon(equipment.change_selected_item(equipment.selected_item))
	
	
func change_weapon(new_weapon:Weapon):
	weapon.stop_animation()
	if self.is_ancestor_of(weapon):
		remove_child(weapon)
	add_child(new_weapon)
	self.weapon = new_weapon
	self.weapon.character_team = get_meta("team", -1)
	
func deal_damage(damage:float):
	health -= damage
