extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 50

var players = { }
var _server
var _client

func _ready():
	if get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected') != OK:
		print("Failed to connect \"network_peer_disconnected\"")

	if get_tree().connect('network_peer_connected', self, '_on_player_connected') != OK:
		print("Failed to connect \"network_peer_connected\"")

func create_server():
	self._server = WebSocketServer.new()

	var crypto = Crypto.new()
	var key = CryptoKey.new()
	var cert = X509Certificate.new()

	# key.load("cert/cert.key")
	# cert.load("cert/cert.crt")

	key.load("cert/privkey.pem")
	cert.load("cert/fullchain.pem")



	# var key = crypto.generate_rsa(4096)
	# var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")
	_server.private_key = key
	_server.ssl_certificate = cert

	self._server.listen(DEFAULT_PORT, PoolStringArray(), true)
	get_tree().set_network_peer(self._server)

func connect_to_server(ipaddress):
	if get_tree().connect('connected_to_server', self, '_connected_to_server') != OK:
		print("Failed to connect \"connected_to_server\"")
	self._client = WebSocketClient.new()

	var url = "wss://"+ipaddress+":"+str(DEFAULT_PORT)
	self._client.connect_to_url(url, PoolStringArray(), true)
	get_tree().set_network_peer(self._client)

func _on_player_disconnected(id):
	print("A player disconnected")
	players.erase(id)

func _on_player_connected(id):
	players[id] = "player"

	if get_tree().is_network_server():
		var root = get_tree().get_root().get_node("root")
		root.resend_shared_map()
		root.resend_objects()
		print("player_connected")



func _process(delta):
	if self._server != null && self._server.is_listening():
		self._server.poll()

	if self._client != null && (self._client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || self._client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		self._client.poll()
