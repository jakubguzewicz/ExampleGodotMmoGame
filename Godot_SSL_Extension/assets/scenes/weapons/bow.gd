extends Weapon

func _init():
	animation_prefix = "bow"

signal spawn_projectile(projectile:CharacterBody2D)
const ARROW = preload("res://assets/scenes/weapons/arrow.tscn")

@onready var hitbox = $Hitbox

enum AttackState{
	Attacking,
	Ready
}

@export var can_animate_walking := true
@export var attack_state := AttackState.Ready
@export var damage := 20.0

func attack():
	if attack_state == AttackState.Ready:
		can_animate_walking = false
		animation_player.play(animation_prefix+"/attack")
		
func animate_walking():
	if can_animate_walking:
		animation_player.play(animation_prefix+"/walk")

func animate_idle():
	if can_animate_walking:
		animation_player.play(animation_prefix+"/idle")

func spawn_projectile_func():
	var projectile = ARROW.instantiate()
	projectile.character_team = character_team
	projectile.damage = damage
	projectile.rotation = global_rotation
	projectile.position = global_position + Vector2(0, -50).rotated(projectile.rotation)
	projectile.velocity = Vector2(0, -projectile.linear_speed).rotated(projectile.rotation)
	spawn_projectile.emit(projectile)
