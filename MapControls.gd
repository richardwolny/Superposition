extends Control

signal map_changed(filename)


func _ready():
	$HBoxContainer/MapMenuButton.get_popup().connect("id_pressed", self, "_on_MapMenuButton_popup_id_pressed")


func _on_MapMenuButton_popup_id_pressed(id):
	var filename = $HBoxContainer/MapMenuButton.get_popup().get_item_text(id)
	$HBoxContainer/CurrentMapLabel.text = filename
	emit_signal("map_changed", filename)


func _on_LoadMapButton_pressed():
	$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path):
	$HBoxContainer/CurrentMapLabel.text = path
	emit_signal("map_changed", path)
