extends Node


enum MoveMode {
	AUTO,
	CENTER,
	CORNER,
	EDGE_X,
	EDGE_Z,
}


var enabled: bool = true
var move_mode: int = MoveMode.AUTO
