extends Node

enum Scene {
	LOG_IN,
	LOG_IN_SUCCESS,
	CLIENT_GAME
}

var scenes_array := Array()

func _init():
	scenes_array.resize(Scene.size())
	scenes_array[Scene.LOG_IN] = preload("res://scenes/log_in/log_in_scene.tscn")
	scenes_array[Scene.LOG_IN_SUCCESS] = preload("res://scenes/log_in/log_in_success.tscn")
	scenes_array[Scene.CLIENT_GAME] = preload("res://scenes/client/client_game.tscn")
