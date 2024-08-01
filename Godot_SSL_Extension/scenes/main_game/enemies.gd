extends Node

@onready var interactables = %Interactables

var enemy_id_counter := 2000

func _ready():
	for enemies_spawner in get_children():
		if not enemies_spawner is CharacterBody2D:
			enemies_spawner.spawn_enemy_signal.connect(_on_spawn_enemy)

	
func _on_spawn_enemy(enemy):
	enemy.enemy_id = enemy_id_counter
	enemy_id_counter += 1
	add_child(enemy)
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.item_dropped.connect(interactables.add_interactable)
	
func _on_enemy_died(enemy):
	enemy.queue_free()
