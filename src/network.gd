extends Node


signal player_connected()

const DEFAULT_PORT = 31400
const IS_SSL_ENABLED = true

var _peer
var _players = {}


func _ready():
	if get_tree().connect('network_peer_connected', self, '_on_network_peer_connected') != OK:
		print("Failed to connect \"network_peer_connected\"")

	if get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected') != OK:
		print("Failed to connect \"network_peer_disconnected\"")

	if get_tree().connect('connected_to_server', self, '_on_connected_to_server') != OK:
		print("Failed to connect \"connected_to_server\"")

	if get_tree().connect('connection_failed', self, '_on_connection_failed') != OK:
		print("Failed to connect \"connection_failed\"")

	if get_tree().connect('server_disconnected', self, '_on_server_disconnected') != OK:
		print("Failed to connect \"server_disconnected\"")


func create_server():
	_peer = WebSocketServer.new()

	if IS_SSL_ENABLED:
		var key = CryptoKey.new()
		var cert = X509Certificate.new()
		key.load("cert/privkey.pem")
		cert.load("cert/fullchain.pem")
#		key.load("cert/cert.key")
#		cert.load("cert/cert.crt")
#		var crypto = Crypto.new()
#		var key = crypto.generate_rsa(4096)
#		var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")
		_peer.private_key = key
		_peer.ssl_certificate = cert

	_peer.listen(DEFAULT_PORT, PoolStringArray(), true)
	get_tree().set_network_peer(_peer)


func connect_to_server(ip_address):
	_peer = WebSocketClient.new()

	var prefix = "wss://" if IS_SSL_ENABLED else "ws://"
	var url = prefix + ip_address + ":" + str(DEFAULT_PORT)

	_peer.connect_to_url(url, PoolStringArray(), true)
	get_tree().set_network_peer(_peer)


func _on_network_peer_connected(id):
	print("network_peer_connected: " + str(id))
	_players[id] = "player"
	emit_signal("player_connected")


func _on_network_peer_disconnected(id):
	print("network_peer_disconnected: " + str(id))
	_players.erase(id)


func _on_connected_to_server():
	print("connected_to_server")


func _on_connection_failed():
	print("connection_failed")


func _on_server_disconnected():
	print("server_disconnected")
