class_name Map
extends TileMapLayer

@export var first_slice : PackedScene
@export var slices : Array[PackedScene]
@export var number_of_slices := 10

# height in number of tiles of the whole map
var _height := 0

func _ready() -> void:
	var first_slice_instance : TileMapSlice = first_slice.instantiate()
	add_slice_to_map(first_slice_instance)
	first_slice_instance.free() # not sure if necessary
	
	for i in number_of_slices:
		randomize() # Randomizes the seed (or the internal state) of the random number generator
		var slice_instance : TileMapSlice = slices[randi() % slices.size()].instantiate()
		add_slice_to_map(slice_instance)
		slice_instance.free() # not sure if necessary

func take_damage_at(coords : Vector2i):
	var sid := self.get_cell_source_id(coords)
	var atlas_coords := self.get_cell_atlas_coords(coords)
	if atlas_coords == Vector2i(0,0): # full health -> lower health
		atlas_coords = Vector2i(0,1)
	elif atlas_coords == Vector2i(0,1): # lower health -> lowest health
		atlas_coords = Vector2i(0,2)
	elif atlas_coords == Vector2i(0,2): # lowest health -> remove cell
		sid = -1 # delete cell
	self.set_cell(coords, sid, atlas_coords)

func add_slice_to_map(slice : TileMapSlice):
	var w := slice.get_width()
	var h := slice.get_height()
	
	# copy slice to the end of the map
	for x in w:
		for y in h:
			var coords := Vector2i(x,y)
			var sid := slice.get_cell_source_id(coords)
			var atlas_coords := slice.get_cell_atlas_coords(coords)
			var alt_tile_id := slice.get_cell_alternative_tile(coords)
			
			var map_coords := coords + Vector2i(0,_height)
			self.set_cell(map_coords, sid, atlas_coords, alt_tile_id)
	_height += h
