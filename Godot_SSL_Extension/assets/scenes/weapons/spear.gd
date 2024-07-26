extends Weapon

func _init():
	animation_prefix = "spear"

@onready var hitbox = $Hitbox

enum AttackState{
	Attacking,
	Ready
}

@export var can_animate_walking := true
@export var attack_state := AttackState.Ready
@export var damage := 15.0

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
		
func _on_weapon_hit(body):
	if body.get_meta("is_damagable", true):
		body.deal_damage(damage)
