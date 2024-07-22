class_name Equipment
extends Node

signal equipment_changed()

var equipment_array := Array()
var selected_item := 0

func _ready():
	equipment_array.resize(8)

func replace_item(index:int, item) -> Error:
	if index < 0 or index > equipment_array.size():
		printerr("Tried to add equipment item to slot number higher than equipment size")
		return ERR_PARAMETER_RANGE_ERROR
	else:
		equipment_array[index] = item
		equipment_changed.emit()
		return OK
	
func pop_item(index:int) -> Object:
	var removed_item = equipment_array[index]
	equipment_array[index] = null
	equipment_changed.emit()
	return removed_item
	
func remove_item(index:int):
	equipment_array.remove_at(index)
	equipment_changed.emit()

func change_selected_item(index:int) -> Weapon:
	selected_item = index
	return equipment_array[index]
