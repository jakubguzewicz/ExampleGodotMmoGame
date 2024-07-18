extends CharacterBody2D

@onready var sprite_2d := $Sprite2D
@onready var weapon:Weapon = get_node_or_null("Weapon")


func _process(delta):
	#sprite_2d.position = Engine.get_physics_interpolation_fraction()/Engine.physics_ticks_per_second*Input.get_vector("move_left","move_right","move_up","move_down")*velocity.length()	
	pass

func attack():
	if weapon:
		weapon.attack()

func animate_walking():
	weapon.animate_walking()
	
func animate_idle():
	weapon.animate_idle()
