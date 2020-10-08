extends Control


signal map_changed(filename)
signal share_room()
signal unhide_tile()
signal create_circle(name, color, radius)
signal create_square(name, color, edge_length)
signal create_mini(name, color, model_index)
signal delete()
signal toggle_ping(is_enabled)
signal toggle_walls(show_walls)
signal up_level()
signal down_level()
signal popup_toggled(is_showing)

var _generator_type = null;
var _recent_circle_size = "5"
var _recent_square_size = "10"

onready var _recent_circle_name = $NameGenerator.spell_name()
onready var _recent_square_name = $NameGenerator.spell_name()
onready var _recent_mini_name = $NameGenerator.mini_name()


func _ready():
	$MapControls/MapMenu.get_popup().connect("id_pressed", self, "_on_MapMenu_popup_id_pressed")
	$CreatePopup.hide()
	for i in range(len(get_parent().models)):
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Model/OptionButton.add_item(get_parent().models[i][0], i)


func set_share_room_disabled(disabled):
	$RoomControls/ShareRoom.disabled = disabled


func set_unhide_tile_disabled(disabled):
	$RoomControls/UnhideTile.disabled = disabled


func set_object_selected(is_selected):
	if is_selected:
		$PlayerControls/Delete.disabled = false
	else:
		$PlayerControls/Delete.disabled = true


func set_current_floor(current_floor):
	$PlayerControls/Floor.text = "Floor: " + str(current_floor)


func _on_MapMenu_popup_id_pressed(id):
	var filename = $MapControls/MapMenu.get_popup().get_item_text(id)
	$MapControls/CurrentMap.text = "Current Map: " + filename
	emit_signal("map_changed", filename)


func _on_LoadMap_pressed():
	emit_signal("popup_toggled", true)
	$FileDialog.popup_centered()


func _on_FileDialog_file_selected(path):
	$MapControls/CurrentMap.text = "Current Map: " + filename
	emit_signal("map_changed", path)


func _on_ShareRoom_pressed():
	emit_signal("share_room")


func _on_UnhideTile_pressed():
	emit_signal("unhide_tile")


func _on_Popup_pressed():
	emit_signal("popup_toggled", false)
	_generator_type = null
	$CreatePopup.hide()


func _on_CreateCircle_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = "circle"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_circle_name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text = _recent_circle_size
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/Label.text = "Radius:"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size.show()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
	$CreatePopup.show()


func _on_CreateSquare_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = "square"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_square_name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text = _recent_square_size
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/Label.text = "Edge Length:"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size.show()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
	$CreatePopup.show()


func _on_CreateMini_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = "mini"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_mini_name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size.hide()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.show()
	$CreatePopup.show()


func _on_GenerateRandom_pressed():
	if _generator_type == "circle":
		_recent_circle_name = $NameGenerator.spell_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_circle_name
	elif _generator_type == "square":
		_recent_square_name = $NameGenerator.spell_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_square_name
	elif _generator_type == "mini":
		_recent_mini_name = $NameGenerator.mini_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_mini_name


func _on_Create_pressed():
	emit_signal("popup_toggled", false)
	var name = $CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text
	var color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
	if _generator_type == "circle":
		var size = $CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text
		emit_signal("create_circle", name, color, size)
	elif _generator_type == "square":
		var size = $CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text
		emit_signal("create_square", name, color, size)
	elif _generator_type == "mini":
		var model_index = $CreatePopup/Center/Panel/VBox/HBox/VBox/Model/OptionButton.get_selected_id()
		emit_signal("create_mini", name, color, model_index)

	_generator_type = null
	$CreatePopup.hide()


func _on_Name_LineEdit_text_changed(new_text):
	if _generator_type == "circle":
		_recent_circle_name = new_text
	elif _generator_type == "square":
		_recent_square_name = new_text
	elif _generator_type == "mini":
		_recent_mini_name = new_text


func _on_Size_LineEdit_text_changed(new_text):
	if _generator_type == "circle":
		_recent_circle_size = new_text
	elif _generator_type == "square":
		_recent_square_size = new_text


func _on_Delete_pressed():
	emit_signal("delete")


func _on_Ping_toggled(button_pressed):
	emit_signal("toggle_ping", button_pressed)


func _on_Walls_toggled(button_pressed):
	emit_signal("toggle_walls", button_pressed)


func _on_UpLevel_pressed():
	emit_signal("up_level")


func _on_DownLevel_pressed():
	emit_signal("down_level")
