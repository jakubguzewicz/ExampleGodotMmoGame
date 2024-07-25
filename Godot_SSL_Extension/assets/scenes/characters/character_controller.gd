extends Node

@onready var player_character := $PlayerCharacter
@onready var camera := $PlayerCharacter/Camera2D
@onready var projectiles := %Projectiles
@onready var equipment:Equipment = $PlayerCharacter/Equipment
@onready var interactables = %Interactables

# TODO
# Temporary node loading, should probably be autoloaded equipment library
const AXE = preload("res://assets/scenes/weapons/axe.tscn")
const BOW = preload("res://assets/scenes/weapons/bow.tscn")
const SPEAR = preload("res://assets/scenes/weapons/spear.tscn")

#This one is not guaranteed, to be changed later

const SPEED = 800.0
const CAMERA_MOVEMENT_RATIO = 150.0
const INTERACT_RANGE = 100.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
	# To be changed later, added for testing
	equipment.replace_item(0, AXE.instantiate())
	equipment.replace_item(1, BOW.instantiate())
	equipment.replace_item(2, SPEAR.instantiate())
	
	change_equipped_item(1)
	
	#equipment.item_dropped.connect(_on_player_dropped_item)
	
func _on_player_dropped_item(item, _transform):
	disconnect_all_signals(item)
	
	
func change_equipped_item(index:int):
	if player_character.weapon:
		disconnect_all_signals(player_character.weapon)
		var new_weapon = equipment.change_selected_item(index)
		player_character.change_weapon(new_weapon)
		if player_character.weapon.has_signal("spawn_projectile"):
			player_character.weapon.spawn_projectile.connect(spawn_projectile)
	
func disconnect_all_signals(signal_caller:Object):
	for sig in signal_caller.get_signal_list():
		for connection in signal_caller.get_signal_connection_list(sig.name):
			if connection.callable.get_object() == self:
				connection.signal.disconnect(connection.callable)

func _input(event):
	
	# Handle attack input
	if event.is_action_pressed("attack"):
		player_character.attack()
		
	## Camera controls:
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
		
	## Weapon Changing
	if event.is_action_pressed(&"weapon_down"):
		weapon_down()
	elif event.is_action_pressed(&"weapon_up"):
		weapon_up()
	elif event.is_action_pressed(&"weapon_slot_1"):
		change_weapon_to(0)
	elif event.is_action_pressed(&"weapon_slot_2"):
		change_weapon_to(1)
	elif event.is_action_pressed(&"weapon_slot_3"):
		change_weapon_to(2)
	elif event.is_action_pressed(&"weapon_slot_4"):
		change_weapon_to(3)
	elif event.is_action_pressed(&"weapon_slot_5"):
		change_weapon_to(4)
	elif event.is_action_pressed(&"weapon_slot_6"):
		change_weapon_to(5)
	elif event.is_action_pressed(&"weapon_slot_7"):
		change_weapon_to(6)
	elif event.is_action_pressed(&"weapon_slot_8"):
		change_weapon_to(7)
	elif event.is_action_pressed(&"drop_item"):
		drop_selected_item()
		
	if event.is_action_pressed("interact"):
		interactables.interact(player_character)
	
func drop_selected_item():
	player_character.drop_selected_item()

func weapon_up():
	var new_weapon_index := (equipment.selected_item-1) % equipment.equipment_array.size()
	change_equipped_item(new_weapon_index)
	#player_character.change_weapon(equipment.change_selected_item(new_weapon_index))
	
func weapon_down():
	var new_weapon_index := (equipment.selected_item+1) % equipment.equipment_array.size()
	change_equipped_item(new_weapon_index)	
	#player_character.change_weapon(equipment.change_selected_item(new_weapon_index))
	
func change_weapon_to(index:int):
	change_equipped_item(index)
	#player_character.change_weapon(equipment.change_selected_item(index))


func _physics_process(_delta):

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
	
	# Simulate physics
	player_character.move_and_slide()
	
	# Check for closest interactable
	var closest_interactable_dict = interactables.find_closest(player_character)
	if closest_interactable_dict.distance < INTERACT_RANGE:
		if player_character.selected_interactable != closest_interactable_dict["interactable"]:
			if player_character.selected_interactable != null:
				player_character.selected_interactable.highlight = false
			player_character.selected_interactable = closest_interactable_dict["interactable"]
			player_character.selected_interactable.highlight = true
	else:
		if player_character.selected_interactable != null:
			player_character.selected_interactable.highlight = false
			player_character.selected_interactable = null

func spawn_projectile(projectile:CharacterBody2D):
	projectiles.add_child(projectile)
