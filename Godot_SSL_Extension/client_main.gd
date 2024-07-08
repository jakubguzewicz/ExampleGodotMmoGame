extends Node2D

var log_in_scene = preload("res://log_in/log_in_scene.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.add_child.call_deferred(log_in_scene)

