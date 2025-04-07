class_name Player
extends RigidBody2D

@export var movementInput : Vector2;
@export var maxSpeed : float = 50.0;
@export var acell : float = 100.0;
@export var laser_damage_per_second := 7.5
@export var hits_per_second := 6.0
@export var knockback := 1.0

@export var health : float = 50;

@onready var uBootSprite : Sprite2D = $Submarine;
@onready var torpedo_rampe : Node2D = $Submarine/CannonSpawn
@onready var laserLine : Line2D = $Submarine/LaserSpriteParent/LaserPunkt/Line2D
@onready var laser_blob : MeshInstance2D = $Submarine/LaserSpriteParent/LaserPunkt/LaserBlob
@onready var propellerAnimation : AnimationPlayer = $PropellerAnimation
@onready var laser_sprite : Node2D = $Submarine/LaserSpriteParent
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var ray_cast_start : Node2D = $Submarine/LaserSpriteParent/RayCastStart
@onready var health_bar : ProgressBar = $HealthBar

@export var rocket : PackedScene;

var rocketCooldown : float = 1.0;
var uBootDir : Vector2 = Vector2.ZERO;

var _last_laser_rid : RID
var _last_laser_rid_change_time : int

var is_dead : bool = false

func _ready() -> void:
	laserLine.add_point(Vector2.ZERO)
	laserLine.add_point(Vector2.ZERO)
	propellerAnimation.play("spin")
	propellerAnimation.speed_scale = 0.1
	animationPlayer.play("idle")
	health_bar.set_max_health(health)

func spawn_rocket():
	var rocket_instance = rocket.instantiate()
	rocket_instance.global_position = torpedo_rampe.global_position
	rocket_instance.get_child(0).linear_velocity += self.linear_velocity
	get_tree().root.add_child(rocket_instance)
	pass;

func _process(_delta):
	if health <= 0.0 and not is_dead:
		_kill_player()
	rocketCooldown -= _delta

func _physics_process(delta):
	movementInput = Vector2.ZERO;
	
	if Input.is_action_pressed("Horizontal_plus"):
		movementInput.x += 1
	if Input.is_action_pressed("Horizontal_minus"):
		movementInput.x -= 1
	if Input.is_action_pressed("Vertical_minus"):
		movementInput.y += 1
	if Input.is_action_pressed("Vertical_plus"):
		movementInput.y -= 1
	
	if movementInput.length() > 1.0:
		movementInput = movementInput.normalized();
	
	if rocketCooldown > 0:
		rocketCooldown -= delta;
	
	var lookPos = get_global_mouse_position();
	var myPos = self.global_position;
	
	var targetVec = lookPos - myPos;
	
	if myPos.x < lookPos.x:
		targetVec = -targetVec
		uBootSprite.scale.x = -abs(uBootSprite.scale.x)
	else:
		uBootSprite.scale.x = abs(uBootSprite.scale.x)
	
	uBootDir = lerp(uBootDir, targetVec, delta * 2.0);
	uBootSprite.look_at(myPos - uBootDir)
	
	self.apply_force(movementInput * acell);
	
	laser_sprite.look_at(get_global_mouse_position())
	laserLine.visible = false
	laser_blob.visible = false
	
	if rocketCooldown <= 0:
		rocketCooldown -= delta
		
	if Input.is_action_just_pressed("mouse_click") && rocketCooldown <= 0:
		spawn_rocket()
		rocketCooldown = 3.0
		
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		laserLine.visible = true
		laser_blob.visible = true
		
		var space_state = get_world_2d().direct_space_state
		var start := ray_cast_start.global_position
		var direction := (get_global_mouse_position() - start).normalized()
		var target := start + direction * 1000.0
		var query := PhysicsRayQueryParameters2D.create(start, target)
		var exc := query.exclude # copy it and assign it again, otherwise it doesnt work
		exc.append(self.get_rid()) # dont collide with self
		query.exclude = exc
		
		var result : Dictionary = space_state.intersect_ray(query)
		var hit_position := target # if nothing is hit, a very far away point is used as laser ending point
		
		if !result.is_empty():
			hit_position = result.position # used as endpoint for laser
			var obstacles : Map = %ObstaclesTiles
			if result.rid == _last_laser_rid:
				var density := 1.0
				if result.collider == obstacles:
					var coords := obstacles.get_coords_for_body_rid(result.rid)
					var sid := obstacles.get_cell_source_id(coords)
					if sid != -1:
						density = obstacles.get_cell_tile_data(coords).get_custom_data("density")
				if Time.get_ticks_msec() - _last_laser_rid_change_time > (1000.0 * density/hits_per_second):
					if result.collider == obstacles: # destroy cells
						if result.collider == obstacles:
							var coords := obstacles.get_coords_for_body_rid(result.rid)
							obstacles.take_damage_at(coords)
					elif result.collider is Enemy: # damage enemies
						var enemy : Enemy = result.collider
						enemy.take_damage(laser_damage_per_second / hits_per_second)
						enemy.apply_impulse(
							(get_global_mouse_position() - global_position).normalized() * 100.0 * knockback
						)
					elif result.collider is Rocket:
						var rocket : Rocket = result.collider
						rocket.explode()
					
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
	
	var speed = self.linear_velocity.length()
	var t = clamp(speed/ 30.0, 1.0, 3.0)
	propellerAnimation.speed_scale = pow(t, 2)

	
func _integrate_forces(_state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > maxSpeed:
		self.linear_velocity = self.linear_velocity.normalized() * maxSpeed;
	
	self.linear_velocity = self.linear_velocity * 0.95;
	
	pass;

func apply_hit(damage :float):
	if not is_dead:
		print("Hit")
		health -= damage
		health_bar.deal_damage(damage)
		animationPlayer.play("autsch")

func _kill_player():
	print("Game Over")
	animationPlayer.play("die")
	
	is_dead = true
