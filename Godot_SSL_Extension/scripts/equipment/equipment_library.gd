extends Node

enum Weapon {
	EMPTY,
	SPEAR,
	AXE,
	BOW
}

enum AttackState{
	ATTACKING,
	READY
}

var weapon_scenes = Array()

func _init():
	weapon_scenes.resize(Weapon.size())
	weapon_scenes[Weapon.EMPTY] = preload("res://assets/scenes/weapons/empty.tscn")
	weapon_scenes[Weapon.SPEAR] = preload("res://assets/scenes/weapons/spear.tscn")
	weapon_scenes[Weapon.AXE] = preload("res://assets/scenes/weapons/axe.tscn")
	weapon_scenes[Weapon.BOW] = preload("res://assets/scenes/weapons/bow.tscn")
	
func nodes_from_enums(enum_array:Array) -> Array:
	var output_array := Array()
	output_array.resize(enum_array.size())
	for index in enum_array:
		output_array[index] = weapon_scenes[enum_array[index]].instantiate()
	return output_array
	
func enums_from_nodes(node_array:Array) -> Array:
	var output_array := Array()
	output_array.resize(node_array.size())
	for index in node_array:
		output_array[index] = node_array[index].equipment_id
	return output_array
