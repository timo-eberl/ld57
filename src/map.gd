@tool
class_name Map
extends TileMapLayer

@export var first_slice : PackedScene
@export var slices : Array[PackedScene]
@export var number_of_slices := 10
@export_tool_button("Generate Map", "Callable") var generate_map_action = generate_map

@onready var playerController : RigidBody2D = %Player

var water_tile : Vector2i = Vector2i(12,11)
var active_water_blocks_to_check : Array[Vector2i]
var water_update_timer := 0.0


# height in number of tiles of the whole map
var _height := 0

func generate_map():
	_height = 0
	# fill everything with default tile
	for x in range(-30, 50):
		for y in range(-30, 2000):
			self.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
	
	var first_slice_instance : TileMapSlice = first_slice.instantiate()
	add_slice_to_map(first_slice_instance)
	first_slice_instance.free() # not sure if necessary
	
	for i in number_of_slices:
		randomize() # Randomizes the seed (or the internal state) of the random number generator
		var slice_instance : TileMapSlice = slices[randi() % slices.size()].instantiate()
		add_slice_to_map(slice_instance)
		slice_instance.free() # not sure if necessary

func _ready() -> void:
	if !Engine.is_editor_hint():
		generate_map()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
			pass;
	
	if water_update_timer <= 0.0: 
		water_force();
		water_spread();
		water_update_timer = .1
	else:
		water_update_timer -= delta



func water_force():
	for block in active_water_blocks_to_check:
		var target_pull : Vector2 = Vector2(block.x * 64, block.y * 64) - playerController.global_position
		
		if target_pull.length() < 300.0:
			playerController.apply_impulse(target_pull.normalized() * (300 - target_pull.length()))


func water_spread():
	var blocks_to_ceck_to_add : Array[Vector2i];
	
	for block in active_water_blocks_to_check:
		var sorounding = self.get_surrounding_cells(block)
		var found_water = false
		
		for v in sorounding:
			var sid := self.get_cell_source_id(v)
			var atlas_coord := self.get_cell_atlas_coords(v)
			
			if sid == -1:
				blocks_to_ceck_to_add.append(v)
			
			if atlas_coord == water_tile:
				found_water = true
		
		if found_water:
			self.set_cell(block, 0, water_tile)
			
	active_water_blocks_to_check = blocks_to_ceck_to_add
	pass;


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
	
	if sid == -1:
		active_water_blocks_to_check.append(coords)

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
