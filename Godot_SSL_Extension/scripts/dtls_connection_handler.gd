class_name DtlsConnectionHandler extends Node
# Called when the node enters the scene tree for the first time.
signal dtls_message_received(message: PackedByteArray)
signal dtls_session_connected()
signal dtls_session_disconnected()
signal dtls_log_in_pending()

# To be changed for config files
static var client_cert := load("res://certs/client_cert.crt")
var port := 4720
var server_ip_address := "172.23.66.47"
var hostname := "localhost"

var udp_peer := PacketPeerUDP.new()
var dtls_peer := PacketPeerDTLS.new()
var tls_options := TLSOptions.client(client_cert)


func _ready():
	udp_peer.connect_to_host(server_ip_address, port)
	dtls_peer.connect_to_peer(udp_peer, hostname, tls_options)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dtls_peer.poll()
	if dtls_peer.get_status() == PacketPeerDTLS.STATUS_CONNECTED:
		dtls_session_connected.emit()
		while dtls_peer.get_available_packet_count() > 0:
			dtls_message_received.emit(dtls_peer.get_packet())
	else:
		dtls_session_disconnected.emit()
			
func send_login_message(username:String, password:String):
	if dtls_peer.get_status() == PacketPeerDTLS.STATUS_CONNECTED:
		dtls_log_in_pending.emit()
		#dtls_peer.put_packet(GameMessagesParser.log_in_request(username, password))
	else:
		dtls_session_disconnected.emit()
