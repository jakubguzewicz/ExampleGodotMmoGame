extends Node2D

signal spawn_enemy_signal(enemy)

const BASIC_ENEMY = preload("res://assets/scenes/enemies/basic_enemy.tscn")

var enemies_counter := 0
var max_enemies := 1
	
func spawn_enemy():
	if enemies_counter < max_enemies:
		enemies_counter += 1
		await get_tree().create_timer(3.0).timeout
		var new_enemy = BASIC_ENEMY.instantiate()
		new_enemy.position = global_position
		spawn_enemy_signal.emit(new_enemy)
		new_enemy.enemy_died.connect(_on_enemy_death)
	
func _on_enemy_death(_enemy):
	enemies_counter -= 1
	
func _physics_process(delta):
	spawn_enemy()
