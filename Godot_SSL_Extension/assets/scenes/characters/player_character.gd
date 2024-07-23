extends CharacterBody2D

@onready var sprite_2d := $Sprite2D
@onready var weapon:Weapon = $Weapon
@onready var equipment:Equipment = $Equipment

@export var health := 100.0
@export var gold := 0


func _ready():
	pass
	

func attack():
	if weapon:
		weapon.attack()

func animate_walking():
	if weapon:
		weapon.animate_walking()
	
func animate_idle():
	if weapon:
		weapon.animate_idle()
	
func change_weapon(new_weapon:Weapon):
	weapon.stop_animation()
	remove_child(weapon)
	add_child(new_weapon)
	self.weapon = new_weapon
	self.weapon.character_team = get_meta("team", -1)
	
func deal_damage(damage:float):
	health -= damage
