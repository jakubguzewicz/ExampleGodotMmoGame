extends Node

enum Type {
	ENEMY,
	INTERACTABLE,
	PROJECTILE
}

enum EntityType {
	BASIC_ENEMY,
	ARROW
}

var entity_scenes := Array()

func _init():
	entity_scenes.resize(EntityType.size())
	entity_scenes[0] = preload("res://assets/scenes/enemies/basic_enemy.tscn")
	entity_scenes[1] = preload("res://assets/scenes/weapons/arrow.gd")

func nodes_from_enums(enum_array: Array) -> Array:
	var output_array := Array()
	output_array.resize(enum_array.size())
	for index in enum_array.size():
		output_array[index] = entity_scenes[enum_array[index]].instantiate()
	return output_array
	
func enums_from_nodes(node_array: Array) -> Array:
	var output_array := Array()
	output_array.resize(node_array.size())
	for index in node_array.size():
		output_array[index] = node_array[index].equipment_id
	return output_array
