extends Node


const DEFAULT_PORT = 31400
const IS_SECURE = false

var players = {}

var _server
var _client


func _ready():
	if get_tree().connect('network_peer_connected', self, '_on_network_peer_connected') != OK:
		print("Failed to connect \"network_peer_connected\"")

	if get_tree().connect('network_peer_disconnected', self, '_on_network_peer_disconnected') != OK:
		print("Failed to connect \"network_peer_disconnected\"")


func _process(delta):
	if self._server != null && self._server.is_listening():
		self._server.poll()

	if self._client != null && (self._client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || self._client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		self._client.poll()


func create_server():
	self._server = WebSocketServer.new()

	if IS_SECURE:
		var key = CryptoKey.new()
		var cert = X509Certificate.new()
		key.load("cert/privkey.pem")
		cert.load("cert/fullchain.pem")
#		key.load("cert/cert.key")
#		cert.load("cert/cert.crt")
#		var crypto = Crypto.new()
#		var key = crypto.generate_rsa(4096)
#		var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")
		_server.private_key = key
		_server.ssl_certificate = cert

	self._server.listen(DEFAULT_PORT, PoolStringArray(), true)
	get_tree().set_network_peer(self._server)


func connect_to_server(ip_address):
	if get_tree().connect('connected_to_server', self, '_on_connected_to_server') != OK:
		print("Failed to connect \"connected_to_server\"")

	if get_tree().connect('connection_failed', self, '_on_connection_failed') != OK:
		print("Failed to connect \"connection_failed\"")

	if get_tree().connect('server_disconnected', self, '_on_server_disconnected') != OK:
		print("Failed to connect \"server_disconnected\"")

	self._client = WebSocketClient.new()
	var prefix = "wss://" if IS_SECURE else "ws://"
	var url = prefix + ip_address + ":" + str(DEFAULT_PORT)
	self._client.connect_to_url(url, PoolStringArray(), true)
	get_tree().set_network_peer(self._client)


func _on_network_peer_connected(id):
	print("network_peer_connected: " + str(id))
	players[id] = "player"

	if get_tree().is_network_server():
		var root = get_tree().get_root().get_node("root")
		root.resend_shared_map()
		root.resend_objects()


func _on_network_peer_disconnected(id):
	print("network_peer_disconnected: " + str(id))
	players.erase(id)


func _on_connected_to_server():
	print("connected_to_server")


func _on_connection_failed():
	print("connection_failed")


func _on_server_disconnected():
	print("server_disconnected")
