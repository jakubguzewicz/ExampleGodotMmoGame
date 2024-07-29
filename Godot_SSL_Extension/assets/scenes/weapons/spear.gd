extends Weapon

func _init():
	animation_prefix = "spear"
	equipment_id = EquipmentLibrary.Weapon.SPEAR

@onready var hitbox = $Hitbox


@export var can_animate_walking := true
@export var attack_state := EquipmentLibrary.AttackState.READY
@export var damage := 15.0

func attack():
	if attack_state == EquipmentLibrary.AttackState.READY:
		can_animate_walking = false
		animation_player.play(animation_prefix+"/attack")
		
func animate_walking():
	if can_animate_walking:
		animation_player.play(animation_prefix+"/walk")

func animate_idle():
	if can_animate_walking:
		animation_player.play(animation_prefix+"/idle")
		
func animate_attack():
	## only for server update use, do not use for input reaction
	can_animate_walking = false
	animation_player.play(animation_prefix+"/attack")
		
func _on_weapon_hit(body):
	if body.get_meta("is_damagable", true):
		body.deal_damage(damage)
