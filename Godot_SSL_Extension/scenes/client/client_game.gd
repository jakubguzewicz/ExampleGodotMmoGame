extends Node2D

@onready var controlled_character = $MainGame/Characters/ControlledCharacter
@onready var main_game = %MainGame

@onready var characters_node = main_game.get_node(^"Characters")
@onready var projectiles_node = main_game.get_node(^"Projectiles")
@onready var interactables_node = main_game.get_node(^"Interactables")

const PLAYER_CHARACTER = preload("res://assets/scenes/characters/player_character.tscn")

var input_dict := Dictionary()

func _ready():
	DtlsConnection.dtls_message_received.connect(process_message)
	controlled_character.action_inputted.connect(process_input)
	
func setup_game(join_world_response_dict:Dictionary):
	var character_data:Array = join_world_response_dict["character_data"]
	var equipment_array:Array = character_data[0]
	var character_transform:Array = character_data[1]
	
	controlled_character.player_character.position = character_transform[0]
	controlled_character.player_character.rotation = character_transform[1]
	controlled_character.player_character.equipment.equipment_array = EquipmentLibrary.nodes_from_enums(equipment_array)
	controlled_character.player_character.change_equipped_item(0)
	
func process_message(message:PackedByteArray):
	var message_dict := GameMessagesParser.parse_from_byte_array(message)
	if message_dict["message_type"] == GameMessagesEnums.MessageType.SERVER_UPDATE_STATE:
		update_game_state(message_dict)
	pass
	
func update_game_state(server_update_message_dict:Dictionary):
	var characters = characters_node.get_children()
	var projectiles = projectiles_node.get_children()
	var interactables = interactables_node.get_children()
	
	
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
				characters_node.add_child(new_character)
				if new_character.weapon.equipment_id != data[1][0]:
					new_character.change_weapon(EquipmentLibrary.weapon_scenes[data[1][0]])
			else:
				target_character[0].position = data[0][0]
				target_character[0].rotation = data[0][1]
				target_character[0].velocity = data[0][2]
				if target_character[0].weapon.equipment_id != data[1][0]:
					target_character.change_weapon(EquipmentLibrary.weapon_scenes[data[1][0]])
				if data[1][1] == EquipmentLibrary.AttackState.ATTACKING:
					target_character.weapon.animate_attack()
				
	for entity_data in server_update_message_dict["entities_update_data"]:
		pass
	pass
	
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

func process_input(action:int):
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
	
