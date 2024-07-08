extends Node2D

var log_in_success:PackedScene = preload("res://log_in/log_in_success.tscn")

enum State {
	NOT_CONNECTED,
	CONNECTED,
	LOG_IN_PENDING,
}

var log_in_state := State.NOT_CONNECTED

func _on_log_in_button_log_in_pressed(username, password):
	var dtls_connection:DtlsConnectionHandler
	if log_in_state == State.NOT_CONNECTED:
		dtls_connection = DtlsConnectionHandler.new()
		dtls_connection.dtls_message_received.connect(_process_game_message)
		
		#add_child(dtls_connection)
	if log_in_state == State.LOG_IN_PENDING:
		return
	else:
		dtls_connection.send_login_message(username, password)

func _session_connected():
	log_in_state = State.CONNECTED
	
func _log_in_pending():
	log_in_state = State.LOG_IN_PENDING
	
func _session_disconnected():
	log_in_state = State.NOT_CONNECTED
	
func _process_game_message(message:PackedByteArray):
	pass
