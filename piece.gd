class_name Piece
extends StaticBody

signal animation_finished

const FLOATMATH_FUZZ = 0.00001

var movement_speed = 20
var rotation_speed = 8
var floor_number = 0
var tile_size

var _target_position = Vector2(1, 1)
var _target_rotation = Vector3(0, 0, 0)

var _position_animation = false
var _rotation_animation = false


func _process(delta):
	if (_position_animation):
		var current_position = Vector2(self.transform.origin.x, self.transform.origin.z)
		var distance = _target_position - current_position
		if (distance.length() <= movement_speed * delta):
			self.transform.origin.x = _target_position.x
			self.transform.origin.z = _target_position.y
			_position_animation = false
			end_move_floor_change()
			hide_show_on_floor()
		else:
			var movement = distance.normalized() * movement_speed
			self.global_translate(Vector3(movement.x * delta, 0, movement.y * delta))

	if (_rotation_animation):
		var current_position = self.global_transform.origin
		var current_forward = self.global_transform.basis.z
		var current_side = self.global_transform.basis.x

		var target_direction = _target_rotation - current_position
		var angle_to_target = current_forward.angle_to(target_direction)
		var dot_to_target = current_side.dot(target_direction)

		if angle_to_target > rotation_speed * delta:
			angle_to_target = rotation_speed * delta
		else:
			_rotation_animation = false

		if dot_to_target < 0.0:
			angle_to_target *= -1

#		var axis = current_forward.cross(_target_rotation)
		self.rotate_y(angle_to_target)


func set_selected():
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", true)
	surface_material.next_pass.set_shader_param("enable", true)


func set_deselected():
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", false)
	surface_material.next_pass.set_shader_param("enable", false)


func end_move_floor_change():
	pass


func hide_show_on_floor():
	var main = get_tree().get_root().get_node("Main")
	if main.current_floor+0.9 > self.floor_number && main.current_floor - 0.9 < self.floor_number:
		self.transform.origin.y = (self.floor_number - main.current_floor)*2
	else:
		self.transform.origin.y = 99999999


func move_to(coordinate, target_floor):
	var snapped_centerpoint = Vector2(
			floor(coordinate.x / 2) * 2 + 1,
			floor(coordinate.z / 2) * 2 + 1
		)

	if tile_size % 2 == 0:
		snapped_centerpoint = Vector2(
			floor((coordinate.x + 1) / 2) * 2,
			floor((coordinate.z + 1) / 2) * 2
		)

	rpc("move_to_NETWORK", snapped_centerpoint, target_floor)


remotesync func move_to_NETWORK(coordinate, target_floor):
	self._target_position = coordinate
	self.floor_number = target_floor
	hide_show_on_floor()
	self._position_animation = true


func rotate_to(target_direction):
	rpc("rotate_to_NETWORK", target_direction)


remotesync func rotate_to_NETWORK(target_direction):
	self._target_rotation = target_direction
	self._rotation_animation = true


func delete():
	rpc("delete_NETWORK")


remotesync func delete_NETWORK():
	var main = get_tree().get_root().get_node("Main")
	if main.selected_object == self:
		main.deselect_object()
	self.queue_free()
	if main.circles.has(self.name):
		main.circles.erase(self.name)
	if main.squares.has(self.name):
		main.squares.erase(self.name)
	if main.minis.has(self.name):
		main.minis.erase(self.name)
