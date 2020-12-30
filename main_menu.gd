extends CenterContainer


signal start_game()


func _ready():
	if not (OS.has_feature("dungeon_master") or OS.has_feature("editor")):
		$VBoxContainer/VBoxContainer/Host.visible = false

	$VBoxContainer/Version.text = "Version: " + Version.id()


func _on_HostGame_pressed():
	Network.create_server()
	emit_signal("start_game")


func _on_JoinGame_pressed():
	Network.connect_to_server($VBoxContainer/VBoxContainer/IpAddress.text)
	emit_signal("start_game")
