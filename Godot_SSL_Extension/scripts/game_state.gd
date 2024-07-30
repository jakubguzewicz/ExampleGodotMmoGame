extends Node

enum State {
	NOT_CONNECTED,
	CONNECTING,
	CONNECTED,
	LOG_IN_PENDING,
	LOGGED_IN,
	JOINED_WORLD
}

var current_state := State.NOT_CONNECTED
var user_id := 0
var username := ""
