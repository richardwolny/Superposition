extends "res://object.gd"


func _ready():
	self.movement_speed = 20
	self.rotation_speed = 8


func set_object_selected():
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", true)
	surface_material.next_pass.set_shader_param("enable", true)


func set_object_deselected():
	var surface_material = self.get_node("mesh").get_surface_material(0)
	surface_material.set_shader_param("enable", false)
	surface_material.next_pass.set_shader_param("enable", false)


func end_move_floor_change():
	var root = get_tree().get_root().get_node("root")

	var x = floor(self.transform.origin.x/2)
	var y = floor(self.transform.origin.z/2)
	
	print(Vector2(x,y))
	var tile = root.sparse_map_lookup(
		root.shared_sparse_map,
		x,
		y,
		floor(self.floor_number)
	)

	if tile != null:
		if tile.tile_type == "stairsup":
			self.floor_number = self.floor_number + .5
		if tile.tile_type == "stairsdown":
			self.floor_number = self.floor_number - .5

	# Redraw rooms so that we can see new fog of war areas
	root.redraw_gridmap_tiles()
