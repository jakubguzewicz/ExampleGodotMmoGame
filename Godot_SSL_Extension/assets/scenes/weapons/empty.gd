extends Weapon

var animation_prefix := "empty"

func animate_walking():
	animation_player.play(animation_prefix+"/walk")

func animate_idle():
	animation_player.play(animation_prefix+"/idle")
