extends "res://object.gd"

func _ready():
	self.movement_speed = 9999999
	self.rotation_speed = 1

func set_object_selected():
	var surface_material = $sprite/viewport/texture/sprite.material
	surface_material.set_shader_param("enabled", true)

func set_object_deselected():
	var surface_material = $sprite/viewport/texture/sprite.material
	surface_material.set_shader_param("enabled", false)
