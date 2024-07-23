extends Node2D

@onready var equipment = $Characters/ControlledCharacter/PlayerCharacter/Equipment
@onready var equipment_bar = $HUD/EquipmentBar


func _ready():
	equipment.equipment_changed.connect(_on_equipment_change)
	
	# TODO remove after testing
	_on_equipment_change(equipment.equipment_array, equipment.selected_item)
	
	
func _on_equipment_change(equipment_array:Array, selected_weapon:int):
	equipment_bar.refresh_equipment_bar(equipment_array, selected_weapon)
