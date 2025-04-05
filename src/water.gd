extends TileMapLayer

@onready var obstacle_tiles : Map = $"../ObstaclesTiles"


# TODO do this only when destroying stone and only in an area around the destroyed stone
func _process(_delta: float) -> void:
	# change some cells to water
	for x in range(-50, 50):
		for y in range(-50, 100):
			var coords := Vector2i(x,y)
			var sid := obstacle_tiles.get_cell_source_id(coords)
			# if no obstacle is at the cell, spawn water
			if sid == -1:
				var atlas_coords := Vector2i(12,11) # water atlas coordinates
				var alt_tile_id := 1 # different ids -> different opacity
				self.set_cell(coords, 0, atlas_coords, alt_tile_id)
			else:
				# delete cell
				self.set_cell(coords, -1, Vector2i(-1,-1))
