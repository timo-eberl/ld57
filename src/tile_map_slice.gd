class_name TileMapSlice
extends TileMapLayer

func get_height() -> int:
	var y := 0
	while true:
		var coords := Vector2i(0,y)
		var sid := self.get_cell_source_id(coords)
		if sid == -1:
			return y
		y += 1
	return 0

func get_width() -> int:
	var x := 0
	while true:
		var coords := Vector2i(x,0)
		var sid := self.get_cell_source_id(coords)
		if sid == -1:
			return x
		x += 1
	return 0
