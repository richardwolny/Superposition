extends StaticBody

signal animation_finished

var target_position = Vector2(1,1)
var target_rotation = 0

var translation_animation = false
var rotation_animation = false

var movement_speed = 20
var rotation_speed = 1

var tile_size
var floor_number = 0

func end_move_floor_change():
	pass

func hide_show_on_floor():
	var root = get_tree().get_root().get_node("root")
	if root.current_floor+0.9 > self.floor_number && root.current_floor - 0.9 < self.floor_number:
		self.transform.origin.y = (self.floor_number - root.current_floor)*2
	else:
		self.transform.origin.y = 99999999


func move_to(coordinate, target_floor):
	var snapped_centerpoint = Vector2(
			floor(coordinate.x/2)*2+1,
			floor(coordinate.z/2)*2+1
		)
	
	if tile_size%2 == 0:
		snapped_centerpoint = Vector2(
			floor((coordinate.x+1)/2)*2,
			floor((coordinate.z+1)/2)*2
		)

	rpc("move_to_NETWORK", snapped_centerpoint, target_floor)

const seconds = 0.5
remotesync func move_to_NETWORK(coordinate, target_floor):
	self.target_position = coordinate



	self.floor_number = target_floor
	hide_show_on_floor()

	#self.movement_speed = (self.target_position - self.transform.origin).length() / seconds
	# self.rotation_speed = (self.target_rotation - self.rotation).length() / seconds

	self.translation_animation = true

func delete():
	rpc("delete_NETWORK")

remotesync func delete_NETWORK():
	var root = get_tree().get_root().get_node("root")
	if root.selected_object == self:
		root.deselect_object()
	self.queue_free()
	if root.circles.has(self.name):
		root.circles.erase(self.name)
	if root.squares.has(self.name):
		root.squares.erase(self.name)
	if root.minis.has(self.name):
		root.minis.erase(self.name)

func set_object_selected():
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", true)
	surface_material.next_pass.set_shader_param("enable", true)

func set_object_deselected():
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", false)
	surface_material.next_pass.set_shader_param("enable", false)





################################################################################
# Not really normalize float, but determine the sign of a float. maybe there is a better way
# to handle something like this
################################################################################
func normalize_float(float_val):
	if float_val == 0:
		return 1 # default to positive if zero
	return float_val / abs(float_val)

################################################################################
# There is a bug with fposmod that allows for above the max value to be hit when perfoming a modulo on the
# negative of the maximum. So in the meantime this function will be used and will preform a check to 
# fix that issue. https://github.com/godotengine/godot/pull/19279
################################################################################
func normalize_spin(spin):
	var max_spin = deg2rad(360)
	var normalized_spin = fposmod(spin,max_spin)
	if (normalized_spin == max_spin):
		return 0
	return normalized_spin

################################################################################
#
################################################################################
func rotation_distance(start, end):
	start = normalize_spin(start)
	end = normalize_spin(end) # we may want to move this out if it is expensive

	var distance = end - start
	if (distance > deg2rad(180)):
		distance = distance - deg2rad(360)
	if (distance < deg2rad(-180)):
		distance = distance + deg2rad(360)
	return distance




var floatmath_fuzz = 0.00001
func _process(delta):
	# Animate movement twards target
	if (translation_animation):
		var current_position = Vector2(self.transform.origin.x, self.transform.origin.z)
		var distance = target_position - current_position
		if (distance.length() <= movement_speed*delta):
			self.transform.origin.x = target_position.x
			self.transform.origin.z = target_position.y
			translation_animation = false
			end_move_floor_change()
			hide_show_on_floor()
			if not  rotation_animation:
				self.emit_signal("animation_finished")

		else:
			var movement = distance.normalized() * movement_speed
			self.global_translate(
				Vector3(
					movement.x*delta,
					0,
					movement.y*delta
				)
			)
	
	# Animate rotation twards target
	if (rotation_animation):
		# X Rotation
		# var x_rotation_delta = rotation_distance(self.rotation.x, target_rotation.x)
		# if (abs(x_rotation_delta) <= (rotation_speed * delta) + floatmath_fuzz):
		# 	self.rotation.x = target_rotation.x
		# else:
		# 	self.rotation.x = self.rotation.x + rotation_speed*delta * normalize_float(x_rotation_delta)
		# Y rotation
		var y_rotation_delta = rotation_distance(self.rotation.y, target_rotation.y)
		if (abs(y_rotation_delta) <= (rotation_speed * delta) + floatmath_fuzz):
			self.rotation.y = target_rotation.y
		else:
			self.rotation.y = self.rotation.y + rotation_speed*delta * normalize_float(y_rotation_delta)
		# Z rotation
		# var z_rotation_delta = rotation_distance(self.rotation.z, target_rotation)
		# if (abs(z_rotation_delta) <= (rotation_speed * delta) + floatmath_fuzz):
		# 	self.rotation.z = target_rotation
		# else:
		# 	self.rotation.z = self.rotation.z + rotation_speed*delta * normalize_float(z_rotation_delta)

		# if (x_rotation_delta == 0 && y_rotation_delta == 0 && z_rotation_delta == 0):
		if (y_rotation_delta == 0):
			rotation_animation = false
			if not translation_animation:
				self.emit_signal("animation_finished")
