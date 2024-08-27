class_name Interactable
extends Node2D

@onready var miniature:Sprite2D = $Miniature

var interactable_id := 0

var highlight:bool = false: set = set_higlight

func set_higlight(value):
	if value == true:
		miniature.modulate = Color(1.0, 1.0, 0.3, 1.0)
	if value == false:
		miniature.modulate = Color(1.0, 1.0, 1.0, 1.0)
