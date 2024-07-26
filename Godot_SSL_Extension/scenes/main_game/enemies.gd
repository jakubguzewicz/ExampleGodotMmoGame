extends Node

@onready var basic_enemies_spawner = $BasicEnemiesSpawner
@onready var interactables = %Interactables

func _process(delta):
	pass

func _ready():
	basic_enemies_spawner.spawn_enemy_signal.connect(_on_spawn_enemy)
	
func _on_spawn_enemy(enemy):
	add_child(enemy)
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.item_dropped.connect(interactables.add_interactable)
	
func _on_enemy_died(enemy):
	enemy.queue_free()
