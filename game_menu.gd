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

enum SettingId {
	MANUAL_SNAP_OPTIONS,
}

enum GeneratorType {
	CIRCLE,
	SQUARE,
	MINI,
}

var _generator_type = null;
var _recent_circle_size = "5"
var _recent_square_size = "10"

onready var _recent_circle_name = $NameGenerator.spell_name()
onready var _recent_square_name = $NameGenerator.spell_name()
onready var _recent_mini_name = $NameGenerator.mini_name()
onready var _recent_circle_color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
onready var _recent_square_color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
onready var _recent_mini_color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color


func _ready():
	$MapControls.hide()
	$RoomControls.hide()
	$CreatePopup.hide()

	$MapControls/MapMenu.get_popup().connect("id_pressed", self, "_on_MapMenu_popup_id_pressed")

	$PlayerControls/Settings.get_popup().add_check_item("Show Manual Snap Options", SettingId.MANUAL_SNAP_OPTIONS)
	var index: int = $PlayerControls/Settings.get_popup().get_item_index(SettingId.MANUAL_SNAP_OPTIONS)
	$PlayerControls/Settings.get_popup().set_item_checked(index, Snap.manual_options_enabled)
	$PlayerControls/Settings.get_popup().connect("id_pressed", self, "_on_Settings_popup_id_pressed")

	for mode in Snap.MoveMode.keys():
		$PlayerControls/SnapMode.add_item(mode)
	$PlayerControls/SnapMode.select(Snap.move_mode)
	_update_manual_snap_options(Snap.manual_options_enabled)

	$PlayerControls/SnapRotate.pressed = Snap.rotate_on

	for i in range(len(get_parent().models)):
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Model/OptionButton.add_item(get_parent().models[i][0], i)


func show_dm_controls():
	$MapControls.show()
	$RoomControls.show()


func set_share_room_disabled(disabled):
	$RoomControls/ShareRoom.disabled = disabled


func set_unhide_tile_disabled(disabled):
	$RoomControls/UnhideTile.disabled = disabled


func set_selected(is_selected):
	if is_selected:
		$PlayerControls/Delete.disabled = false
	else:
		$PlayerControls/Delete.disabled = true


func update_snap_mode():
	assert(not $PlayerControls/SnapMode.is_item_disabled(Snap.move_mode))
	$PlayerControls/SnapMode.select(Snap.move_mode)


func set_ping_pressed(is_pressed):
	$PlayerControls/Ping.pressed = is_pressed


func set_current_floor(current_floor):
	$PlayerControls/Floor.text = "Floor: " + str(current_floor)


func _update_manual_snap_options(manual_snap_options_enabled: bool) -> void:
	var disabled: bool = not manual_snap_options_enabled
	$PlayerControls/SnapMode.set_item_disabled(Snap.MoveMode.CENTER, disabled)
	$PlayerControls/SnapMode.set_item_disabled(Snap.MoveMode.CORNER, disabled)
	$PlayerControls/SnapMode.set_item_disabled(Snap.MoveMode.EDGE_X, disabled)
	$PlayerControls/SnapMode.set_item_disabled(Snap.MoveMode.EDGE_Z, disabled)


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


func _on_FileDialog_popup_hide():
	print("_on_FileDialog_popup_hide")
	emit_signal("popup_toggled", false)


func _on_ShareRoom_pressed():
	emit_signal("share_room")


func _on_UnhideTile_pressed():
	emit_signal("unhide_tile")


func _on_Settings_popup_id_pressed(id: int):
	var popup: PopupMenu = $PlayerControls/Settings.get_popup()
	var index: int = popup.get_item_index(id)
	match id:
		SettingId.MANUAL_SNAP_OPTIONS:
			var is_checked: bool = not popup.is_item_checked(index)
			popup.set_item_checked(index, is_checked)
			Snap.manual_options_enabled = is_checked
			_update_manual_snap_options(is_checked)
			if not is_checked:
				if Snap.move_mode != Snap.MoveMode.OFF and Snap.move_mode != Snap.MoveMode.AUTO:
					Snap.move_mode = Snap.MoveMode.AUTO
					$PlayerControls/SnapMode.select(Snap.MoveMode.AUTO)


func _on_SnapRotate_toggled(button_pressed):
	Snap.rotate_on = button_pressed


func _on_CreatePopup_pressed():
	emit_signal("popup_toggled", false)
	_generator_type = null
	$CreatePopup.hide()


func _on_CreateCircle_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = GeneratorType.CIRCLE
	$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_circle_color
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_circle_name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text = _recent_circle_size
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/Label.text = "Radius:"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size.show()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
	$CreatePopup.show()


func _on_CreateSquare_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = GeneratorType.SQUARE
	$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_square_color
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_square_name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text = _recent_square_size
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size/Label.text = "Edge Length:"
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size.show()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
	$CreatePopup.show()


func _on_CreateMini_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = GeneratorType.MINI
	$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_mini_color
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_mini_name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Size.hide()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.show()
	$CreatePopup.show()


func _on_GenerateRandom_pressed():
	if _generator_type == GeneratorType.CIRCLE:
		_recent_circle_name = $NameGenerator.spell_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_circle_name
	elif _generator_type == GeneratorType.SQUARE:
		_recent_square_name = $NameGenerator.spell_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_square_name
	elif _generator_type == GeneratorType.MINI:
		_recent_mini_name = $NameGenerator.mini_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_mini_name


func _on_Create_pressed():
	emit_signal("popup_toggled", false)
	var name = $CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text
	var color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
	print(color)
	if _generator_type == GeneratorType.CIRCLE:
		var size = $CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text
		emit_signal("create_circle", name, color, size)
	elif _generator_type == GeneratorType.SQUARE:
		var size = $CreatePopup/Center/Panel/VBox/HBox/VBox/Size/LineEdit.text
		emit_signal("create_square", name, color, size)
	elif _generator_type == GeneratorType.MINI:
		var model_index = $CreatePopup/Center/Panel/VBox/HBox/VBox/Model/OptionButton.get_selected_id()
		emit_signal("create_mini", name, color, model_index)

	_generator_type = null
	$CreatePopup.hide()


func _on_ColorPicker_color_changed(color):
	if _generator_type == GeneratorType.CIRCLE:
		_recent_circle_color = color
	elif _generator_type == GeneratorType.SQUARE:
		_recent_square_color = color
	elif _generator_type == GeneratorType.MINI:
		_recent_mini_color = color


func _on_Name_LineEdit_text_changed(new_text):
	if _generator_type == GeneratorType.CIRCLE:
		_recent_circle_name = new_text
	elif _generator_type == GeneratorType.SQUARE:
		_recent_square_name = new_text
	elif _generator_type == GeneratorType.MINI:
		_recent_mini_name = new_text


func _on_Size_LineEdit_text_changed(new_text):
	if _generator_type == GeneratorType.CIRCLE:
		_recent_circle_size = new_text
	elif _generator_type == GeneratorType.SQUARE:
		_recent_square_size = new_text


func _on_SnapMode_item_selected(index):
	Snap.move_mode = index


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
