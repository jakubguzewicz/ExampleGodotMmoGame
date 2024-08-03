extends Node2D

@onready var controlled_character = $MainGame/Characters/ControlledCharacter
@onready var main_game = %MainGame

signal change_scene(new_scene: PackedScene)
signal change_scene_to_node(new_scene_node: Node)

var LOG_IN_SCENE = SceneManager.scenes_array[SceneManager.Scene.LOG_IN]

@onready var characters_node = main_game.get_node(^"Characters")
@onready var projectiles_node = main_game.get_node(^"Projectiles")
@onready var interactables_node = main_game.get_node(^"Interactables")
@onready var enemies_node = main_game.get_node(^"Enemies")

const PLAYER_CHARACTER = preload("res://assets/scenes/characters/player_character.tscn")

var input_dict := Dictionary()

func _ready():
	DtlsConnection.dtls_message_received.connect(process_message)
	DtlsConnection.dtls_session_disconnected.connect(_process_disconnect)
	controlled_character.action_inputted.connect(process_input)
	controlled_character.change_equipped_item(0)
	
func setup_game(join_world_response_dict: Dictionary):
	var character_data: Array = join_world_response_dict["character_data"]
	var character_id = character_data[0]
	var equipment_array: Array = character_data[1]
	var character_transform: Array = character_data[2]
	
	controlled_character.player_character.position = character_transform[0]
	controlled_character.player_character.rotation = character_transform[1]
	controlled_character.player_character.equipment.equipment_array = EquipmentLibrary.nodes_from_enums(equipment_array)
	controlled_character.player_character.character_id = character_id
	
func process_message(message: PackedByteArray):
	var message_dict := GameMessagesParser.parse_from_byte_array(message)
	if message_dict["message_type"] == GameMessagesEnums.MessageType.SERVER_UPDATE_STATE:
		update_game_state(message_dict)
	pass
	
func update_game_state(server_update_message_dict: Dictionary):
	var characters = characters_node.get_children()
	var projectiles = projectiles_node.get_children()
	var interactables = interactables_node.get_children()
	var enemies = enemies_node.get_children()
	
	var updated_objects := Array()
	var not_updated_objects := Array()
	
	## Update characters
	for character_data in server_update_message_dict["characters_update_data"]:
		var id = character_data["character_id"]
		var data = character_data["character_state"]
		
		## different processing, when working with our character
		if id == controlled_character.player_character.character_id:
			# If size is 3, then we have eq change
			if data.size() == 3:
				for index in controlled_character.equipment.equipment_array.size():
					if data[2][index] != controlled_character.equipment.equipment_array[index].equipment_id:
						controlled_character.equipment.replace_item(EquipmentLibrary.weapon_scenes[data[2][index]].instantiate())
		else:
			var target_character = characters.filter(func(character): return character.character_id == id)
			if target_character.size() == 0:
				# there is no character with given id, need to spawn it
				var new_character = PLAYER_CHARACTER.instantiate()
				new_character.position = data[0][0]
				new_character.rotation = data[0][1]
				new_character.velocity = data[0][2]
				new_character.character_id = id
				characters_node.add_child(new_character)
				if new_character.weapon.equipment_id != data[1][0]:
					new_character.change_weapon(EquipmentLibrary.weapon_scenes[data[1][0]])
				updated_objects.append(new_character)
			else:
				target_character[0].position = data[0][0]
				target_character[0].rotation = data[0][1]
				target_character[0].velocity = data[0][2]
				if target_character[0].weapon.equipment_id != data[1][0]:
					target_character.change_weapon(EquipmentLibrary.weapon_scenes[data[1][0]])
				if data[1][1] == EquipmentLibrary.AttackState.ATTACKING:
					target_character.weapon.animate_attack()
				updated_objects.append(target_character[0])
				
	## Clear not updated characters
	not_updated_objects = characters.filter(func(character): return character not in updated_objects)
	for character in not_updated_objects:
		if character is CharacterBody2D:
			character.queue_free()
	updated_objects.clear()
				
	## Update entities
	updated_objects.resize(EntityLibrary.Type.size())
	for type in EntityLibrary.Type.values():
		updated_objects[type] = Array()
	for entity_data in server_update_message_dict["entities_update_data"]:
		var entity_id = entity_data[1]
		var entity_type = entity_data[2]
		var entity_new_data = entity_data[3]
		match entity_data[0]:
			EntityLibrary.Type.ENEMY:
				var target_enemy = enemies.filter(func(enemy): return enemy.enemy_id == entity_id)
				if target_enemy.size() == 0:
					# there is no enemy with given id, need to spawn it
					var new_enemy = EntityLibrary.entity_scenes[entity_type].instantiate()
					new_enemy.position = entity_new_data[0]
					new_enemy.rotation = entity_new_data[1]
					new_enemy.velocity = entity_new_data[2]
					new_enemy.enemy_id = entity_id
					updated_objects[EntityLibrary.Type.ENEMY].append(new_enemy)
					enemies_node.add_child(new_enemy)
				else:
					target_enemy[0].position = entity_new_data[0]
					target_enemy[0].rotation = entity_new_data[1]
					target_enemy[0].velocity = entity_new_data[2]
					updated_objects[EntityLibrary.Type.ENEMY].append(target_enemy[0])
			EntityLibrary.Type.INTERACTABLE:
				var target_interactable = interactables.filter(func(interactable): return interactable.interactable_id == entity_id)
				if target_interactable.size() == 0:
					# there is no interactable with given id, need to spawn it
					var new_interactable = interactables_node.add_interactable(EquipmentLibrary.weapon_scenes[entity_type].instantiate(), Transform2D(entity_data[3][1], entity_data[3][0]), entity_id)
					updated_objects[EntityLibrary.Type.INTERACTABLE].append(new_interactable)
				else:
					target_interactable[0].position = entity_new_data[0]
					target_interactable[0].rotation = entity_new_data[1]
					updated_objects[EntityLibrary.Type.INTERACTABLE].append(target_interactable[0])
			EntityLibrary.Type.PROJECTILE:
				var target_projectile = projectiles.filter(func(projectile): return projectile.entity_id == entity_id)
				if target_projectile.size() == 0:
					# there is no projectile with given id, need to spawn it
					var new_projectile = EntityLibrary.entity_scenes[entity_type].instantiate()
					new_projectile.position = entity_new_data[0]
					new_projectile.rotation = entity_new_data[1]
					new_projectile.velocity = entity_new_data[2]
					new_projectile.entity_id = entity_id
					projectiles_node.add_child(new_projectile)
					updated_objects[EntityLibrary.Type.PROJECTILE].append(new_projectile)
				else:
					target_projectile[0].position = entity_new_data[0]
					target_projectile[0].rotation = entity_new_data[1]
					target_projectile[0].velocity = entity_new_data[2]
					updated_objects[EntityLibrary.Type.PROJECTILE].append(target_projectile[0])
					
	## Remove unupdated entities
	# Enemies
	not_updated_objects = enemies.filter(func(enemy): return enemy not in updated_objects[EntityLibrary.Type.ENEMY])
	for enemy in not_updated_objects:
		if enemy is CharacterBody2D:
			enemy.queue_free()
	# Interactables
	not_updated_objects = interactables.filter(func(interactable): return interactable not in updated_objects[EntityLibrary.Type.INTERACTABLE])
	for interactable in not_updated_objects:
		if interactable is Interactable:
			interactable.queue_free()
	# Projectiles
	not_updated_objects = projectiles.filter(func(projectile): return projectile not in updated_objects[EntityLibrary.Type.PROJECTILE])
	for projectile in not_updated_objects:
		if projectile is CharacterBody2D:
			projectile.queue_free()
	
func create_client_update() -> Array:
	var update_array := Array()
	var character_transform := Array()
	
	## Set character loc/rot/vel info
	character_transform.resize(3)
	character_transform[0] = controlled_character.player_character.position
	character_transform[1] = controlled_character.player_character.rotation
	character_transform[2] = controlled_character.player_character.velocity
	
	## Create update array to be sent consisting of loc/rot/vel (player state) and actions
	update_array.resize(2)
	update_array[0] = character_transform
	update_array[1] = input_dict.duplicate()
	input_dict.clear()
	
	return update_array

func process_input(action: int):
	match action:
		ActionTypes.Types.ATTACK:
			if not input_dict.has(ActionTypes.Types.ATTACK):
				input_dict[ActionTypes.Types.ATTACK] = true
		ActionTypes.Types.DROP_ITEM:
			if not input_dict.has(ActionTypes.Types.DROP_ITEM):
				input_dict[ActionTypes.Types.DROP_ITEM] = controlled_character.player_character.equipment.selected_item
		ActionTypes.Types.INTERACT:
			if not input_dict.has(ActionTypes.Types.INTERACT):
				input_dict[ActionTypes.Types.INTERACT] = true
		ActionTypes.Types.CHANGE_ITEM:
			# Always update to the newest weapon,
			# obviously bug prone when you change weapon and attack in the same frame
			input_dict[ActionTypes.Types.CHANGE_ITEM] = controlled_character.player_character.equipment.selected_item


func _physics_process(_delta):
	## Send update data messages to server
	DtlsConnection.send_client_update_message(GameState.user_id, controlled_character.player_character.character_id, create_client_update())
	pass

func _process_disconnect():
	change_scene.emit(LOG_IN_SCENE)
