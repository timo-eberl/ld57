extends TileMapLayer

func _ready() -> void:
	# change some cells to water
	for x in 10:
		for y in 10:
			var coords := Vector2i(x,y)
			#var sid := self.get_cell_source_id(coords)
			var atlas_coords := Vector2i(12,10)
			
			var alt_tile_id := 2 # different ids -> different opacity
			self.set_cell(coords, 0, atlas_coords, alt_tile_id)
