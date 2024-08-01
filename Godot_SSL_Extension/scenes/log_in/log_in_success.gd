extends Node2D

var CLIENT_GAME = SceneManager.scenes_array[SceneManager.Scene.CLIENT_GAME]
var LOG_IN_SCENE = SceneManager.scenes_array[SceneManager.Scene.LOG_IN]

signal change_scene(new_scene: PackedScene)
signal change_scene_to_node(new_scene_node: Node)

func _ready():
	DtlsConnection.dtls_session_disconnected.connect(_handle_disconnect)
	DtlsConnection.dtls_message_received.connect(_process_message)
	while true:
		DtlsConnection.send_join_world_request_message(GameState.user_id, GameState.user_id)
		await get_tree().create_timer(5.0).timeout
	

func _process_message(message: PackedByteArray):
	var parsed_message := GameMessagesParser.parse_from_byte_array(message)
	if parsed_message["message_type"] == GameMessagesEnums.MessageType.JOIN_WORLD_RESPONSE:
		if parsed_message.has("character_data"):
			GameState.current_state = GameState.State.JOINED_WORLD
			var new_scene_node = CLIENT_GAME.instantiate()
			new_scene_node.setup_game(parsed_message)
			change_scene_to_node.emit(new_scene_node)
		else:
			# I honestly don't know what should happen in this case in this exact game
			change_scene.emit(LOG_IN_SCENE)

func _handle_disconnect():
	change_scene.emit(LOG_IN_SCENE)
