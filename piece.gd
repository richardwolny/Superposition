class_name Piece
extends StaticBody


signal animation_finished

const FLOATMATH_FUZZ: float = 0.00001

var movement_speed: float = 20.0
var rotation_speed: float = 8.0
var floor_number: float = 0.0
var tile_size_x: int = 1
var tile_size_z: int = 1

var _target_position: Vector2 = Vector2(1, 1)
var _target_direction: Vector3 = Vector3(0, 0, 0)

var _position_animation: bool = false
var _rotation_animation: bool = false


func _process(delta: float) -> void:
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
		var current_forward := self.global_transform.basis.z
		var current_side := self.global_transform.basis.x

		var angle_to_target := current_forward.angle_to(_target_direction)
		var dot_to_target := current_side.dot(_target_direction)

		if angle_to_target > rotation_speed * delta:
			angle_to_target = rotation_speed * delta
		else:
			_rotation_animation = false

#		var axis = current_forward.cross(_target_direction)
		self.rotate_y(angle_to_target * sign(dot_to_target))


func set_selected() -> void:
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", true)
	surface_material.next_pass.set_shader_param("enable", true)


func set_deselected() -> void:
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", false)
	surface_material.next_pass.set_shader_param("enable", false)


func end_move_floor_change() -> void:
	pass


func hide_show_on_floor():
	var main = get_tree().get_root().get_node("Main")
	if main.current_floor+0.9 > self.floor_number && main.current_floor - 0.9 < self.floor_number:
		self.transform.origin.y = (self.floor_number - main.current_floor)*2
	else:
		self.transform.origin.y = 99999999


func move_to(position: Vector3, target_floor: int) -> void:
	rpc("move_to_NETWORK", position, target_floor)


remotesync func move_to_NETWORK(position: Vector3, target_floor:int) -> void:
	self._target_position = Vector2(position.x, position.z)
	self.floor_number = target_floor
	hide_show_on_floor()
	self._position_animation = true


func rotate_to(target_direction: Vector3) -> void:
	rpc("rotate_to_NETWORK", target_direction)


remotesync func rotate_to_NETWORK(target_direction: Vector3) -> void:
	self._target_direction = target_direction
	self._rotation_animation = true


func delete() -> void:
	rpc("delete_NETWORK")


remotesync func delete_NETWORK() -> void:
	var main = get_tree().get_root().get_node("Main")
	if main.selected_object == self:
		main.deselect_object()
	self.queue_free()
	if main.minis.has(self.name):
		main.minis.erase(self.name)
	if main.circles.has(self.name):
		main.circles.erase(self.name)
	if main.rectangles.has(self.name):
		main.rectangles.erase(self.name)
