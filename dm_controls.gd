extends Control


signal map_changed(filename)
signal share_room()
signal unhide_tile()


func _ready():
	$MapControls/MapMenu.get_popup().connect("id_pressed", self, "_on_MapMenu_popup_id_pressed")


func set_share_room_disabled(disabled):
	$RoomControls/ShareRoom.disabled = disabled


func set_unhide_tile_disabled(disabled):
	$RoomControls/UnhideTile.disabled = disabled


func _on_MapMenu_popup_id_pressed(id):
	var filename = $MapControls/MapMenu.get_popup().get_item_text(id)
	$MapControls/CurrentMap.text = "Current Map: " + filename
	emit_signal("map_changed", filename)


func _on_LoadMap_pressed():
	$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path):
	$MapControls/CurrentMap.text = "Current Map: " + filename
	emit_signal("map_changed", path)


func _on_ShareRoom_pressed():
	emit_signal("share_room")


func _on_UnhideTile_pressed():
	emit_signal("unhide_tile")
