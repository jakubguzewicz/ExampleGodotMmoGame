extends Node2D

var current_scene_node: Node


# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene_node = preload("res://scenes/log_in/log_in_scene.tscn").instantiate()
	add_child.call_deferred(current_scene_node)
	current_scene_node.logged_in.connect(_on_logged_in)
	

func _on_logged_in():
	change_scene(preload("res://scenes/log_in/log_in_success.tscn"))
	

func change_scene(scene:PackedScene):
	var next_scene_node := scene.instantiate()
	change_scene_to_prepared_node(next_scene_node)
	
func change_scene_to_prepared_node(next_scene_node:Node):
	add_child.call_deferred(next_scene_node)
	current_scene_node.queue_free()
	current_scene_node = next_scene_node
	next_scene_node.change_scene.connect(change_scene)
	next_scene_node.change_scene_to_node.connect(change_scene_to_prepared_node)
	
