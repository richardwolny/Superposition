extends HBoxContainer

signal map_changed(filename)


func _ready():
	$MapMenuButton.get_popup().connect("id_pressed", self, "_on_MapMenuButton_popup_id_pressed")


func _on_MapMenuButton_popup_id_pressed(id):
	var map_name = $MapMenuButton.get_popup().get_item_text(id)
	print(map_name)
	$CurrentMapLabel.text = map_name
	emit_signal("map_changed", map_name)


func _on_LoadMapButton_pressed():
	$FileDialog.popup_centered()
