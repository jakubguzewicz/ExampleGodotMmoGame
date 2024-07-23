class_name Weapon
extends Node2D

@onready var animation_player = $AnimationPlayer

# Do not use this class instances
# Please make inherited concrete classes
# Treat this as an abstract class
var character_team := 0

func attack():
	pass
	
func animate_walking():
	pass

func animate_idle():
	pass

func stop_animation():
	animation_player.play(&"RESET")
