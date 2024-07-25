extends Node2D

@onready var equipment = $Characters/ControlledCharacter/PlayerCharacter/Equipment
@onready var equipment_bar = $HUD/EquipmentBar
@onready var interactables = %Interactables


func _ready():
	equipment.equipment_changed.connect(_on_equipment_change)
	equipment.item_dropped.connect(_on_new_interactable)
	
	# TODO remove after testing
	_on_equipment_change(equipment.equipment_array, equipment.selected_item)
	
	
func _on_equipment_change(equipment_array:Array, selected_weapon:int):
	equipment_bar.refresh_equipment_bar(equipment_array, selected_weapon)
	
func _on_new_interactable(item, pickup_transform:=Transform2D()):
	interactables.add_interactable(item, pickup_transform)
	
