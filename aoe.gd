extends Piece


func _ready() -> void:
	self.movement_speed = 9999999


func set_selected() -> void:
	var surface_material = $sprite/viewport/texture/sprite.material
	surface_material.set_shader_param("enabled", true)


func set_deselected() -> void:
	var surface_material = $sprite/viewport/texture/sprite.material
	surface_material.set_shader_param("enabled", false)
