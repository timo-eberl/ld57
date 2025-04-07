@tool
class_name Map
extends TileMapLayer

@export var first_slice : PackedScene
@export var last_slice : PackedScene
@export var slices : Array[PackedScene]
@export var number_of_slices := 10
@export_tool_button("Generate Map", "Callable") var generate_map_action = generate_map
@export var water_pull_strength := 1.0

@onready var playerController : RigidBody2D = %Player
@onready var playerNavAgent : NavigationAgent2D = %Player/NavigationAgent2D

#NavigationAgent2D

var water_tile : Vector2i = Vector2i(12,11)
var active_water_blocks_to_check : Array[Vector2i]
var water_update_timer := 0.0
var water_was_added_blocks : Array[Vector2i]


# height in number of tiles of the whole map
var _height := 0

func generate_map():
	_height = 0
	self.clear()
	
	# fill everything with default tile
	for x in range(-30, 70):
		for y in range(-20, 2020):
			if x < 0 || x > 42 || y < 0 || y > 1999:
				self.set_cell(Vector2i(x,y), 0, Vector2i(0,6))
			else:
				self.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
	
	var first_slice_instance : TileMapSlice = first_slice.instantiate()
	add_slice_to_map(first_slice_instance)
	first_slice_instance.free() # not sure if necessary
	
	var index := 0
	for i in number_of_slices:
		randomize() # Randomizes the seed (or the internal state) of the random number generator
		var old_index = index
		# two slices beneath each other cant be the same slice
		while old_index == index:
			index = randi() % slices.size()
		var slice_instance : TileMapSlice = slices[index].instantiate()
		add_slice_to_map(slice_instance)
		slice_instance.free() # not sure if necessary
	
	var last_slice_instance : TileMapSlice = last_slice.instantiate()
	add_slice_to_map(last_slice_instance)
	last_slice_instance.free() # not sure if necessary
	
	# add border at bottom
	for x in range(-30, 70):
		var y = _height
		# cringe
		self.set_cell(Vector2i(x,y), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+1), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+2), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+3), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+4), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+5), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+6), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+7), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+8), 0, Vector2i(0,6))
		self.set_cell(Vector2i(x,y+9), 0, Vector2i(0,6))

func _ready() -> void:
	if Engine.is_editor_hint():
		pass;
	
	generate_map()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
			pass;
	
	if water_update_timer <= 0.0: 
		water_force();
		water_spread();
		water_update_timer = .18
	else:
		water_update_timer -= delta

# only call this during _physic_process, damage should be between 1 and 4
func explosion(pos_ws : Vector2, radius : float, damage : int):
	var space_state = get_world_2d().direct_space_state
	var shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, radius)
	
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape_rid = shape_rid
	query.transform = Transform2D(0, pos_ws)
	
	var results = space_state.intersect_shape(query, 512)
	# Release the shape when done with physics queries.
	PhysicsServer2D.free_rid(shape_rid)
	
	for result in results:
		if result.collider == self:
			var coords := self.get_coords_for_body_rid(result.rid)
			for i in damage:
				self.take_damage_at(coords)

func water_force():
	for block in water_was_added_blocks:
		playerNavAgent.target_position = Vector2(block.x * 64, block.y * 64)
		var pullPoint = playerNavAgent.get_next_path_position() - playerController.global_position
		var d := playerNavAgent.target_position.distance_to(playerController.global_position)
		var fm := clampf( (200.0 / d), 0, 1)
		playerController.apply_impulse(pullPoint.normalized() * 100 * water_pull_strength * fm)
	water_was_added_blocks.clear()

func is_water(coords : Vector2i):
	var atlas_coords := self.get_cell_atlas_coords(coords)
	return atlas_coords == water_tile

func water_spread():
	var blocks_to_ceck_to_add : Array[Vector2i];
	
	for block in active_water_blocks_to_check:
		
		var block_sid := self.get_cell_source_id(block)
		if block_sid != -1:
			continue
		
		var sorounding = self.get_surrounding_cells(block)
		var found_water = false
		
		for v in sorounding:
			if is_water(v):
				found_water = true
				
		for v in sorounding:
			var sid := self.get_cell_source_id(v)
			if sid == -1 && found_water:
				if !blocks_to_ceck_to_add.has(v):
					blocks_to_ceck_to_add.append(v)
		
		if found_water:
			self.set_cell(block, 0, water_tile)
			water_was_added_blocks.append(block)
			
	active_water_blocks_to_check = blocks_to_ceck_to_add
	pass;


func take_damage_at(coords : Vector2i):
	var sid := self.get_cell_source_id(coords)
	var atlas_coords := self.get_cell_atlas_coords(coords)
	if atlas_coords == Vector2i(0,0): # full health -> lower health
		atlas_coords = Vector2i(0,1)
	elif atlas_coords == Vector2i(0,1):
		atlas_coords = Vector2i(0,2)
	elif atlas_coords == Vector2i(0,2):
		atlas_coords = Vector2i(0,3)
	elif atlas_coords == Vector2i(0,3): # lowest health -> remove cell
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
	
	# add all child nodes of the slice
	for node in slice.get_children():
		if node is Node2D:
			node.position.y += _height * 64
		self.get_parent().add_child.call_deferred(node.duplicate())
	
	_height += h
