extends CharacterBody2D

signal item_dropped(item, transform:Transform2D)
signal enemy_died(enemy)

const AXE = preload("res://assets/scenes/weapons/axe.tscn")
const BOW = preload("res://assets/scenes/weapons/bow.tscn")
const SPEAR = preload("res://assets/scenes/weapons/spear.tscn")

@export var health := 100.0

var enemy_id := 0

var drop_array := []

func deal_damage(damage:float):
	health -= damage
	if health <= 0.0:
		enemy_defeated()
		
func enemy_defeated():
	for item in drop_array:
		item_dropped.emit(item, global_transform.rotated_local(randf_range(0.0,2*PI)).translated(Vector2(0.0, -10.0)))
	enemy_died.emit(self)
	
func _ready():
	var random_int := randi_range(0,2)
	match random_int:
		0:
			drop_array.append(AXE.instantiate())
		1:
			drop_array.append(SPEAR.instantiate())
		2:
			drop_array.append(BOW.instantiate())
