extends Node

@onready var player_character = $PlayerCharacter
@onready var camera = $PlayerCharacter/Camera2D
@onready var projectiles = %Projectiles

#This one is not guaranteed, to be changed later
@onready var weapon = $PlayerCharacter/Weapon

const SPEED = 800.0
const CAMERA_MOVEMENT_RATIO = 150.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	# Not guaranteed, to be changed later on weapon pickup
	if weapon.has_signal("spawn_projectile"):
		weapon.spawn_projectile.connect(spawn_projectile)

func _input(event):
	
	# Handle attack input
	if event.is_action_pressed("attack"):
		player_character.attack()
		
	# Camera controls:
	# - Mouse
	if event is InputEventMouseMotion:
		var viewport_size := get_viewport().get_visible_rect().size
		var mouse_position:Vector2 = (event.position - viewport_size/2)/(viewport_size/2) * CAMERA_MOVEMENT_RATIO
		var rotation := -mouse_position.angle_to(Vector2.UP)
		player_character.rotation = rotation
		camera.position = mouse_position.rotated(-rotation)
	# - Controller
	if event.is_action("controller_camera"):
		var camera_vector := Input.get_vector("controller_camera_left","controller_camera_right","controller_camera_up","controller_camera_down")
		var rotation := -camera_vector.angle_to(Vector2.UP)
		player_character.rotation = rotation
		camera.position = camera_vector.rotated(-rotation) * CAMERA_MOVEMENT_RATIO
		

func _physics_process(delta):

	# Handle movement
	var speed_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if speed_vector:
		player_character.velocity = speed_vector*SPEED
	else:
		player_character.velocity = player_character.velocity.move_toward(Vector2(0.0, 0.0), SPEED)
		
	# Handle animation
	if player_character.velocity:
		player_character.animate_walking()
	else:
		player_character.animate_idle()

	player_character.move_and_slide()

func spawn_projectile(projectile:CharacterBody2D):
	projectiles.add_child(projectile)
