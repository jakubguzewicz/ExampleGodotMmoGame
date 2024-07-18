extends Weapon

@onready var hitbox = $Hitbox
@onready var animation_player = $AnimationPlayer

enum AttackState{
	Attacking,
	Ready
}

@export var can_animate_walking := true
@export var attack_state := AttackState.Ready

func attack():
	if attack_state == AttackState.Ready:
		can_animate_walking = false
		animation_player.play("spear/attack")
		
func animate_walking():
	if can_animate_walking:
		animation_player.play("spear/walk")

func animate_idle():
	if can_animate_walking:
		animation_player.play("spear/idle")
