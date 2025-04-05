extends RigidBody2D

@export var movementInput : Vector2;
@export var maxSpeed : float = 50.0;
@export var acell : float = 100.0;
@export var laser_damage_per_second := 7.5
@export var hits_per_second := 6.0

@export var health : float = 50;

@onready var uBootSprite : Sprite2D = $Submarine;
@onready var laser : Node2D = $Submarine/LaserPunkt
@onready var laserLine : Line2D = $Submarine/LaserPunkt/Line2D;
@onready var propellerAnimation : AnimationPlayer = $PropellerAnimation

var rocketCooldown : float = 100.0;
var uBootDir : Vector2 = Vector2.ZERO;

var _last_laser_rid : RID
var _last_laser_rid_change_time : int

var is_dead : bool = false

func _ready() -> void:
	laserLine.add_point(Vector2.ZERO)
	laserLine.add_point(Vector2.ZERO)
	propellerAnimation.play("spin")
	propellerAnimation.speed_scale = 0.1
	pass;

func _process(delta):
	if health <= 0.0 and not is_dead:
		_kill_player()

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
	
	laserLine.visible = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		laserLine.visible = true
		
		var space_state = get_world_2d().direct_space_state
		var start := laserLine.global_position
		var direction := (get_global_mouse_position() - start).normalized()
		var target := start + direction * 10000.0
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
				if Time.get_ticks_msec() - _last_laser_rid_change_time > (1000.0/hits_per_second):
					if result.collider == obstacles: # destroy cells
						if result.collider == obstacles:
							var coords := obstacles.get_coords_for_body_rid(result.rid)
							obstacles.take_damage_at(coords)
					elif result.collider is Enemy: # damage enemies
						var enemy : Enemy = result.collider
						enemy.enemy_stats.health -= laser_damage_per_second / hits_per_second
					
					_last_laser_rid_change_time = Time.get_ticks_msec()
			else:
				_last_laser_rid = result.rid
				_last_laser_rid_change_time = Time.get_ticks_msec()
		else:
			_last_laser_rid = RID()
			_last_laser_rid_change_time = Time.get_ticks_msec()
		laserLine.set_point_position(1, laserLine.to_local(hit_position))
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
	print("Hit")
	health -= damage

func _kill_player():
	print("Game Over")
	visible = false
	
	is_dead = true
