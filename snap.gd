extends Node


enum MoveMode {
	OFF,
	AUTO,
	CENTER,
	CORNER,
	EDGE_X,
	EDGE_Z,
}

var manual_options_enabled: bool = false
var move_mode: int = MoveMode.AUTO
var rotate_on: bool = true


func cycle_move_mode() -> void:
	match move_mode:
		MoveMode.OFF:
			move_mode = MoveMode.AUTO
		MoveMode.AUTO:
			if manual_options_enabled:
				move_mode = MoveMode.CENTER
			else:
				move_mode = MoveMode.OFF
		MoveMode.CENTER:
			move_mode = MoveMode.CORNER
		MoveMode.CORNER:
			move_mode = MoveMode.EDGE_X
		MoveMode.EDGE_X:
			move_mode = MoveMode.EDGE_Z
		MoveMode.EDGE_Z:
			move_mode = MoveMode.OFF
