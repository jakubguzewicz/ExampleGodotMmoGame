extends Node2D

var log_in_success:PackedScene = SceneManager.scenes_array[SceneManager.Scene.LOG_IN_SUCCESS]
@onready var log_in_message_label = $LogInMessageLabel

signal started_connecting()
signal logged_in()

func _on_log_in_button_log_in_pressed(username, password) -> void:
	log_in_message_label.text = ""
	if GameState.current_state == GameState.State.NOT_CONNECTED:
		started_connecting.emit()
		DtlsConnection.new_connection()
		DtlsConnection.dtls_message_received.connect(_process_game_message)
		await DtlsConnection.dtls_session_connected
	DtlsConnection.send_login_message(username, password)

func _session_connected() -> void:
	GameState.current_state = GameState.State.CONNECTED
	
func _log_in_pending() -> void:
	GameState.current_state = GameState.State.LOG_IN_PENDING
	await get_tree().create_timer(10.0).timeout
	if GameState.current_state in [GameState.State.LOG_IN_PENDING]:
		GameState.current_state = GameState.State.CONNECTED
		log_in_message_label.text = "Connection to login server timed out."
	
func _session_disconnected() -> void:
	GameState.current_state = GameState.State.NOT_CONNECTED
	
func _process_game_message(message:PackedByteArray) -> void:
	var message_dict := GameMessagesParser.parse_from_byte_array(message)
	if message_dict["message_type"] == GameMessagesEnums.MessageType.LOG_IN_RESPONSE:
		if message_dict["user_id"] != 0:
			GameState.current_state = GameState.State.LOGGED_IN
			GameState.user_id = message_dict["user_id"]
			GameState.username = message_dict["username"]
			logged_in.emit()
		else:
			log_in_message_label.text = "Incorrect username / password."
			
func _on_started_connecting() -> void:
	GameState.current_state = GameState.State.CONNECTING
	await get_tree().create_timer(11.0).timeout
	if GameState.current_state == GameState.State.CONNECTING:
		log_in_message_label.text = "Could not connect to login server"
		GameState.current_state = GameState.State.NOT_CONNECTED
