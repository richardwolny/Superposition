extends Control


signal map_changed(filename)
signal share_room()
signal unhide_tile()
signal create_mini(name, color, model_index)
signal create_line(name, color, length, width)
signal create_circle(name, color, radius)
signal create_rectangle(name, color, x, z)
signal delete()
signal toggle_ping(is_enabled)
signal toggle_walls(show_walls)
signal up_level()
signal down_level()
signal popup_toggled(is_showing)

enum GeneratorType {
	MINI,
	SPELL,
}

enum SpellShape {
	LINE,
	CIRCLE,
	CONE,
	SQUARE,
	RECTANGLE,
}

class RecentData:
	var color: Color
	var name: String
	var size_a: String
	var size_b: String

var _generator_type = null;

var _recent_mini := RecentData.new()
var _recent_shapes: Array


func _ready():
	$MapControls.hide()
	$RoomControls.hide()
	$CreatePopup.hide()

	$MapControls/MapMenu.get_popup().connect("id_pressed", self, "_on_MapMenu_popup_id_pressed")

	for mode in Snap.MoveMode.keys():
		$PlayerControls/SnapMode.add_item(mode)
	$PlayerControls/SnapMode.select(Snap.move_mode)

	$PlayerControls/SnapOn.pressed = Snap.enabled

	for i in range(len(get_parent().models)):
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Model/OptionButton.add_item(get_parent().models[i][0], i)

	for shape_name in SpellShape.keys():
		print("shape_name: ", shape_name)
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape/OptionButton.add_item(shape_name)

	# I am not sure if SpellShape.keys() is guaranteed to iterate the enum in
	# order. So loop through the enum again to make sure the enum index matches
	# the array index.
	for shape_index in range(SpellShape.size()):
		var recent_data := RecentData.new()
		recent_data.color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
		recent_data.name = $NameGenerator.spell_name()
		_recent_shapes.append(recent_data)

	_recent_shapes[SpellShape.LINE].size_a = "30" # Length
	_recent_shapes[SpellShape.LINE].size_b = "5" # Width

	_recent_shapes[SpellShape.CIRCLE].size_a = "5" # Radius

	_recent_shapes[SpellShape.CONE].size_a = "15" # Radius
	_recent_shapes[SpellShape.CONE].size_b = "30" # Arc Degrees

	_recent_shapes[SpellShape.SQUARE].size_a = "10" # Edge Length

	_recent_shapes[SpellShape.RECTANGLE].size_a = "20" # X Length
	_recent_shapes[SpellShape.RECTANGLE].size_b = "10" # Z Length

	_recent_mini.color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
	_recent_mini.name = $NameGenerator.mini_name()


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


func update_snap_enabled():
	$PlayerControls/SnapOn.pressed = Snap.enabled


func set_ping_pressed(is_pressed):
	$PlayerControls/Ping.pressed = is_pressed


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


func _on_FileDialog_popup_hide():
	print("_on_FileDialog_popup_hide")
	emit_signal("popup_toggled", false)


func _on_ShareRoom_pressed():
	emit_signal("share_room")


func _on_UnhideTile_pressed():
	emit_signal("unhide_tile")


func _on_SnapMode_item_selected(index):
	Snap.move_mode = index


func _on_SnapOn_toggled(button_pressed):
	Snap.enabled = button_pressed


func _on_CreatePopup_pressed():
	emit_signal("popup_toggled", false)
	_generator_type = null
	$CreatePopup.hide()


func _on_CreateMini_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = GeneratorType.MINI
	$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_mini.color
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_mini.name
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.show()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape.hide()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA.hide()
	$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB.hide()
	$CreatePopup.show()


func _show_spell_controls(spell_shape: int) -> void:
	match spell_shape:
		SpellShape.LINE:
			$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_shapes[SpellShape.LINE].color
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_shapes[SpellShape.LINE].name
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/Label.text = "Length:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text = _recent_shapes[SpellShape.LINE].size_a
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/Label.text = "Width:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/LineEdit.text = _recent_shapes[SpellShape.LINE].size_b
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB.show()
		SpellShape.CIRCLE:
			$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_shapes[SpellShape.CIRCLE].color
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_shapes[SpellShape.CIRCLE].name
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/Label.text = "Radius:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text = _recent_shapes[SpellShape.CIRCLE].size_a
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB.hide()
		SpellShape.CONE:
			$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_shapes[SpellShape.CONE].color
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_shapes[SpellShape.CONE].name
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/Label.text = "Distance:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text = _recent_shapes[SpellShape.CONE].size_a
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/Label.text = "Arc:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/LineEdit.text = _recent_shapes[SpellShape.CONE].size_b
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB.show()
		SpellShape.SQUARE:
			$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_shapes[SpellShape.SQUARE].color
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_shapes[SpellShape.SQUARE].name
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/Label.text = "Edge Length:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text = _recent_shapes[SpellShape.SQUARE].size_a
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB.hide()
		SpellShape.RECTANGLE:
			$CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color = _recent_shapes[SpellShape.RECTANGLE].color
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_shapes[SpellShape.RECTANGLE].name
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Model.hide()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/Shape.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/Label.text = "X Length:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text = _recent_shapes[SpellShape.RECTANGLE].size_a
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA.show()
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/Label.text = "Z Length:"
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/LineEdit.text = _recent_shapes[SpellShape.RECTANGLE].size_b
			$CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB.show()
		_:
			print("ERROR: Invalid SpellShape: ", spell_shape)


func GetSelectedShape() -> int:
	return $CreatePopup/Center/Panel/VBox/HBox/VBox/Shape/OptionButton.selected


func _on_CreateSpell_pressed():
	emit_signal("popup_toggled", true)
	_generator_type = GeneratorType.SPELL
	_show_spell_controls(GetSelectedShape())
	$CreatePopup.show()


func _on_GenerateRandom_pressed():
	if _generator_type == GeneratorType.MINI:
		_recent_mini.name = $NameGenerator.mini_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_mini.name
	elif _generator_type == GeneratorType.SPELL:
		var shape_index = GetSelectedShape()
		_recent_shapes[shape_index].name = $NameGenerator.spell_name()
		$CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text = _recent_shapes[shape_index].name


func _on_ColorPicker_color_changed(color):
	if _generator_type == GeneratorType.MINI:
		_recent_mini.color = color
	elif _generator_type == GeneratorType.SPELL:
		var shape_index = GetSelectedShape()
		_recent_shapes[shape_index].color = color


func _on_Shape_OptionButton_item_selected(index):
	_show_spell_controls(index)


func _on_Name_LineEdit_text_changed(new_text):
	if _generator_type == GeneratorType.MINI:
		_recent_mini.name = new_text
	elif _generator_type == GeneratorType.SPELL:
		var shape_index = GetSelectedShape()
		_recent_shapes[shape_index].name = new_text


func _on_SizeA_LineEdit_text_changed(new_text):
	if _generator_type == GeneratorType.SPELL:
		var shape_index = GetSelectedShape()
		_recent_shapes[shape_index].size_a = new_text


func _on_SizeB_LineEdit_text_changed(new_text):
	if _generator_type == GeneratorType.SPELL:
		var shape_index = GetSelectedShape()
		_recent_shapes[shape_index].size_b = new_text


func _on_Create_pressed():
	emit_signal("popup_toggled", false)
	var name = $CreatePopup/Center/Panel/VBox/HBox/VBox/Name/LineEdit.text
	var color = $CreatePopup/Center/Panel/VBox/HBox/ColorPicker.color
	if _generator_type == GeneratorType.MINI:
		var model_index = $CreatePopup/Center/Panel/VBox/HBox/VBox/Model/OptionButton.get_selected_id()
		emit_signal("create_mini", name, color, model_index)
	elif _generator_type == GeneratorType.SPELL:
		var shape_index = GetSelectedShape()
		match shape_index:
			SpellShape.LINE:
				var size_a = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text)
				var size_b = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/LineEdit.text)
				emit_signal("create_line", name, color, size_a, size_b)
			SpellShape.CIRCLE:
				var size_a = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text)
				emit_signal("create_circle", name, color, size_a, 0.0)
			SpellShape.CONE:
				var size_a = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text)
				var size_b = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/LineEdit.text)
				emit_signal("create_circle", name, color, size_a, size_b)
			SpellShape.SQUARE:
				var size_a = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text)
				emit_signal("create_rectangle", name, color, size_a, size_a)
			SpellShape.RECTANGLE:
				var size_a = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeA/LineEdit.text)
				var size_b = int($CreatePopup/Center/Panel/VBox/HBox/VBox/SizeB/LineEdit.text)
				emit_signal("create_rectangle", name, color, size_a, size_b)
	_generator_type = null
	$CreatePopup.hide()





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
