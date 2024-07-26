extends Weapon

func _init():
	animation_prefix = "axe"

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


func _on_weapon_hit(body):
	if body.get_meta("is_damagable", true):
		body.deal_damage(damage)
