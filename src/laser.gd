extends Node2D

@export var laser_offset : float
@onready var laserLine : Line2D = $LaserPunkt/Line2D
@onready var laser_blob : MeshInstance2D = $LaserPunkt/LaserBlob
@onready var ray_cast_start : Node2D = $RayCastStart
@onready var player : Player = get_tree().root.get_child(0).find_child("Player")
@onready var obstacles : Map = get_tree().root.get_child(0).get_node("ObstaclesTiles")

var _last_laser_rid : RID
var _last_laser_rid_change_time : int

func _physics_process(delta):
	
	var start := ray_cast_start.global_position
	var direction := (get_global_mouse_position() - start).normalized()
	var target := start + direction.rotated((laser_offset / 360) * PI * 2.0) * 1000.0
	
	self.look_at(target)
	
	laserLine.visible = false
	laser_blob.visible = false
	
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		laserLine.visible = true
		laser_blob.visible = true
		
		var space_state = get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(start, target)
		var exc := query.exclude # copy it and assign it again, otherwise it doesnt work
		exc.append(player.get_rid()) # dont collide with self
		query.exclude = exc
		query.collision_mask = player.laser_mask
		
		var result : Dictionary = space_state.intersect_ray(query)
		var hit_position := target # if nothing is hit, a very far away point is used as laser ending point
		#var true_laser_level = upgrade_counter.laser_level * upgrade_counter.points_for_upgrade + upgrade_counter.laser_level_progress
		
		
		if !result.is_empty():
			hit_position = result.position # used as endpoint for laser
			var obstacles : Map = obstacles
			if result.rid == _last_laser_rid:
				var density := 1.0
				if result.collider == obstacles:
					var coords := obstacles.get_coords_for_body_rid(result.rid)
					var sid := obstacles.get_cell_source_id(coords)
					if sid != -1:
						density = obstacles.get_cell_tile_data(coords).get_custom_data("density")
					
					#Set density acording to level and depth
					#density += max(0, global_position.y / 1200.0 - true_laser_level)
				if Time.get_ticks_msec() - _last_laser_rid_change_time > (1000.0 * density/player.hits_per_second):
					if result.collider == obstacles: # destroy cells
						if result.collider == obstacles:
							var coords := obstacles.get_coords_for_body_rid(result.rid)
							obstacles.take_damage_at(coords)
					elif result.collider is Enemy: # damage enemies
						var enemy : Enemy = result.collider
						enemy.take_damage(player.laser_damage_per_second / player.hits_per_second)
						enemy.apply_impulse(
							(get_global_mouse_position() - global_position).normalized() * 100.0 * player.knockback
						)
					#elif result.collider is Rocket:
						#var rocket : Rocket = result.collider
						#rocket.explode()
					
					_last_laser_rid_change_time = Time.get_ticks_msec()
			else:
				_last_laser_rid = result.rid
				_last_laser_rid_change_time = Time.get_ticks_msec()
		else:
			_last_laser_rid = RID()
			_last_laser_rid_change_time = Time.get_ticks_msec()
		laserLine.set_point_position(1, laserLine.to_local(hit_position))
		laser_blob.global_position = hit_position
	else:
		_last_laser_rid = RID()
		_last_laser_rid_change_time = Time.get_ticks_msec()
	
	
	
	pass
