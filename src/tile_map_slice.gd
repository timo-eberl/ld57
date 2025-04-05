class_name TileMapSlice
extends TileMapLayer

#func _ready() -> void:
	# change some cells to water
	#for x in 10:
		#for y in 10:
			#var coords := Vector2i(x,y)
			##var sid := self.get_cell_source_id(coords)
			#var atlas_coords := Vector2i(12,10)
			#
			#var alt_tile_id := 2 # different ids -> different opacity
			#self.set_cell(coords, 0, atlas_coords, alt_tile_id)

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
