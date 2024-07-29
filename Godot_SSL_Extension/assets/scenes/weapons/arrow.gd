extends CharacterBody2D

@export var pierce := 0
@export var linear_speed := 3000
@export var damage := 10.0
@export var projectile_range := 1300

var character_team := 0
var _travelled_distance := 0

var entity_id := 0

func _physics_process(delta):
	_check_collisions(delta)
	if _travelled_distance > projectile_range:
		queue_free()
	else:
		_travelled_distance += linear_speed*delta
	
	
func _check_collisions(delta):
	var collider = move_and_collide(velocity * delta, true)
	if collider:
		_on_projectile_hit(collider)
		# Cannot add TileMap to exceptions, so we stop checking collisions
		# if we encounter a TileMap
		if !(collider.get_collider() is TileMap):
			_check_collisions(delta)
	else:
		move_and_collide(velocity * delta)


func _ready():
	velocity = Vector2(0, -linear_speed).rotated(global_rotation)
	position = global_position

func _on_projectile_hit(collider:KinematicCollision2D):
	var collider_object = collider.get_collider()
	if collider_object is PhysicsBody2D:
		add_collision_exception_with(collider_object)
	if collider_object.get_meta("team", -1) == character_team:
		return
	if collider_object.get_meta("is_damagable", false):
		collider_object.deal_damage(damage)
		if pierce > 0:
			pierce -= 1
		else:
			queue_free()
	else:
		queue_free()
