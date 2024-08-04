extends Weapon

@export var attack_state := EquipmentLibrary.AttackState.READY

func _init():
	animation_prefix = "empty"

func animate_walking():
	animation_player.play(animation_prefix+"/walk")

func animate_idle():
	animation_player.play(animation_prefix+"/idle")
