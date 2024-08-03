extends Node2D

const BROKER_HOSTNAME := "broker"
@onready var main_game = %MainGame
@onready var projectiles_node := main_game.get_node(^"Projectiles")
@onready var interactables_node := main_game.get_node(^"Interactables")
@onready var enemies_node := main_game.get_node(^"Enemies")
@onready var characters_node := main_game.get_node(^"Characters")
const PLAYER_CHARACTER = preload("res://assets/scenes/characters/player_character.tscn")

var projectile_id_counter := 3000

# Update database every 60 seconds
var db_update_frequency := 60 * Engine.physics_ticks_per_second
var mongo_connection = MongoConnectionHandler.new()

## Override default client values for server purposes
func _init():
	DtlsConnection.server_ip_address = IP.resolve_hostname(BROKER_HOSTNAME, IP.TYPE_IPV4)
	DtlsConnection.port = 4722

func _ready():
	DtlsConnection.new_connection()
	DtlsConnection.dtls_message_received.connect(_process_message)
	mongo_connection.setup_connection("mongodb://mongodb:27017")
	pass

func _physics_process(_delta):
	_send_server_update()
	if Engine.get_physics_frames() % db_update_frequency == 0:
		_update_database()

func _process_message(message: PackedByteArray):
	var message_dict = GameMessagesParser.parse_from_byte_array(message)
	if message_dict["message_type"] == GameMessagesEnums.MessageType.CLIENT_UPDATE_STATE:
		_process_client_update(message_dict["character_state"])
	elif message_dict["message_type"] == GameMessagesEnums.MessageType.JOIN_WORLD_REQUEST:
		_process_join_world(message_dict["user_id"], message_dict["character_id"])
	pass

func _process_client_update(character_update_dict: Dictionary):
	var character_id = character_update_dict["character_id"]
	var update_data: Array = character_update_dict["character_state"]
	var transform_data = update_data[0]
	var actions_data: Dictionary = update_data[1]
	var characters := characters_node.get_children()
	var updated_character_array = characters.filter(func(character): return character.character_id == character_id)
	if updated_character_array.size() != 0:
		## Update character transforms
		var updated_character = updated_character_array[0]
		updated_character.position = transform_data[0]
		updated_character.rotation = transform_data[1]
		updated_character.velocity = transform_data[2]
		## Process actions made by character
		for action in actions_data.keys():
			match action:
				ActionTypes.Types.ATTACK:
					updated_character.attack()
				ActionTypes.Types.DROP_ITEM:
					updated_character.drop_selected_item()
				ActionTypes.Types.INTERACT:
					var closest_interactable_dict: Dictionary = interactables_node.find_closest(updated_character)
					if closest_interactable_dict.distance < updated_character.INTERACT_RANGE:
						updated_character.selected_interactable = closest_interactable_dict["interactable"]
					else:
						updated_character.selected_interactable = null
					interactables_node.interact(updated_character)
				ActionTypes.Types.CHANGE_ITEM:
					_change_equipped_item(updated_character, action[ActionTypes.Types.CHANGE_ITEM])
	else:
		pass
		## Something went wrong, because character should be added with join world


func _process_join_world(user_id: int, character_id: int):
	## Query db for character_data
	var db_response: Dictionary = mongo_connection.retrieve_character_data(character_id)
	if db_response.is_empty():
		_send_join_world_response(user_id, null)
	else:
		var character_data: Array = db_response["character_data"]
		
		## Add new character or replace currently existing one
		var filtered_characters := characters_node.get_children().filter(func(character): return character.character_id == character_data[0])
		var existing_character = filtered_characters[0] if not filtered_characters.is_empty() else null
		if existing_character:
			## Don't do anything, we shouldn't overwrite new events
			## with database data while character is still in play
			pass
		else:
			## Add new character to the world
			_add_character(character_data)
		_send_join_world_response(user_id, character_data)


func _send_server_update():
	var characters = characters_node.get_children()
	var projectiles = projectiles_node.get_children()
	var interactables = interactables_node.get_children()
	var enemies = enemies_node.get_children()

	## Get characters state
	var characters_update_data := Array()
	for character in characters:
		var character_state := Array()
		character_state.append([character.position, character.rotation, character.velocity])
		character_state.append([character.weapon.equipment_id, character.weapon.attack_state])
		if character.equipment.equipment_changed_since_last_update == true:
			character.equipment.equipment_changed_since_last_update = false
			character_state.append(EquipmentLibrary.enums_from_nodes(character.equipment.equipment_array))
		characters_update_data.append({
		"character_id": character.character_id,
		"character_state": var_to_bytes(character_state)
		})
	var entities_update_data := Array()
	## Get projectiles state
	for projectile in projectiles:
		var projectile_data := Array()
		projectile_data.resize(4)
		projectile_data[0] = EntityLibrary.Type.PROJECTILE
		projectile_data[1] = projectile.entity_id
		## TODO: I HATE this piece of code, need to do something better for that when refactoring
		projectile_data[2] = EntityLibrary.EntityType.ARROW
		projectile_data[3] = [projectile.position, projectile.rotation, projectile.velocity]
		entities_update_data.append(var_to_bytes(projectile_data))
	## Get interactables state
	for interactable in interactables:
		var interactable_data := Array()
		interactable_data.resize(4)
		interactable_data[0] = EntityLibrary.Type.INTERACTABLE
		interactable_data[1] = interactable.interactable_id
		## TODO: Another code I hate, but right now we only have weapons as interactables
		interactable_data[2] = interactable.weapon.equipment_id
		interactable_data[3] = [interactable.position, interactable.rotation]
		entities_update_data.append(var_to_bytes(interactable_data))
	## Get enemies state
	for enemy in enemies:
		# We should only send info about enemies, not spawners
		if enemy is CharacterBody2D:
			var enemy_data := Array()
			enemy_data.resize(4)
			enemy_data[0] = EntityLibrary.Type.ENEMY
			enemy_data[1] = enemy.enemy_id
			## TODO: Do I have to say anything right now?
			enemy_data[2] = EntityLibrary.EntityType.BASIC_ENEMY
			enemy_data[3] = [enemy.position, enemy.rotation, enemy.velocity]
			entities_update_data.append(var_to_bytes(enemy_data))
	
	## Combine all states to server update dictionary
	var server_update_dict := {
		"characters_update_data": characters_update_data,
		"entities_update_data": entities_update_data}

	## Send server update
	DtlsConnection.send_server_update(server_update_dict)


func _send_join_world_response(user_id: int, character_data):
	DtlsConnection.send_join_world_response(user_id, character_data)

func _update_database():
	## We only need to update character position and equipment as of now
	var update_data := Array()
	for character in characters_node.get_children():
		update_data.append({
			"character_id": character.character_id,
			"transform": [character.position, character.rotation],
			"equipment": EquipmentLibrary.enums_from_nodes(character.equipment.equipment_array)
		})
	mongo_connection.update_characters_data(update_data)

func _change_equipped_item(character, index: int):
	if character.weapon:
		_disconnect_all_signals(character.weapon)
		var new_weapon = character.equipment.change_selected_item(index)
		character.change_weapon(new_weapon)
		if character.weapon.has_signal("spawn_projectile"):
			character.weapon.spawn_projectile.connect(_spawn_projectile)

func _disconnect_all_signals(signal_caller: Object):
	for sig in signal_caller.get_signal_list():
		for connection in signal_caller.get_signal_connection_list(sig.name):
			if connection.callable.get_object() == self:
				connection. signal .disconnect(connection.callable)

func _spawn_projectile(projectile: CharacterBody2D):
	projectile.entity_id = projectile_id_counter
	projectile_id_counter += 1
	projectiles_node.add_child(projectile)

func _add_character(character_data: Array):
	var character_id: int = character_data[0]
	var equipment_array: Array = character_data[1]
	var character_transform: Array = character_data[2]
	var new_character = PLAYER_CHARACTER.instantiate()
	new_character.character_id = character_id
	new_character.equipment.equipment_array = EquipmentLibrary.nodes_from_enums(equipment_array)
	new_character.position = character_transform[0]
	new_character.rotation = character_transform[1]
	characters_node.add_child(new_character)
