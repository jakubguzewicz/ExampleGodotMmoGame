class_name Equipment
extends Node

signal equipment_changed(equipment_array: Array, selected_item: int)
signal item_dropped(item, transform: Transform2D)

const EMPTY = preload("res://assets/scenes/weapons/empty.tscn")

var equipment_array := Array()
var selected_item := 0
var equipment_changed_since_last_update := false

func _ready():
	equipment_array.resize(8)
	for index in equipment_array.size():
		equipment_array[index] = EMPTY.instantiate()

func replace_item(index: int, item) -> Error:
	if index < 0 or index > equipment_array.size():
		printerr("Tried to add equipment item to slot number higher than equipment size")
		return ERR_PARAMETER_RANGE_ERROR
	else:
		drop_item(index)
		equipment_array[index] = item
		equipment_changed.emit(equipment_array, selected_item)
		equipment_changed_since_last_update = true
		return OK
	
func drop_item(index: int):
	var item = equipment_array[index]
	if item is Weapon:
		# No need to do anything if no weapon was dropped
		if item.animation_prefix != "empty":
			item.get_parent().remove_child(item)
			remove_item(index)
			item_dropped.emit(item, get_parent().global_transform.rotated_local(randf_range(0.0, 2 * PI)))
			equipment_changed_since_last_update = true

			
func pop_item(index: int) -> Object:
	var removed_item = equipment_array[index]
	equipment_array[index] = null
	equipment_changed.emit(equipment_array, selected_item)
	equipment_changed_since_last_update = true
	return removed_item
	
func remove_item(index: int):
	equipment_changed_since_last_update = true
	replace_with_empty(index)
	
func replace_with_empty(index: int):
	if index < 0 or index > equipment_array.size():
		printerr("Tried to add equipment item to slot number higher than equipment size")
		return ERR_PARAMETER_RANGE_ERROR
	else:
		equipment_array[index] = EMPTY.instantiate()
		equipment_changed.emit(equipment_array, selected_item)
		equipment_changed_since_last_update = true
		return OK

func change_selected_item(index: int) -> Weapon:
	selected_item = index
	equipment_changed.emit(equipment_array, selected_item)
	return equipment_array[index]
