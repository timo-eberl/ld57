class_name Player
extends RigidBody2D

@export var movementInput : Vector2;
@export var maxSpeed : float = 50.0;
@export var acell : float = 100.0;
@export var laser_damage_per_second := 7.5
@export var hits_per_second := 6.0
@export var knockback := 1.0
@export_flags_2d_physics var laser_mask : int

@export var health : float = 50;

@onready var uBootSprite : Sprite2D = $Submarine;
@onready var torpedo_rampe : Node2D = $Submarine/CannonSpawn
@onready var propellerAnimation : AnimationPlayer = $PropellerAnimation
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var health_bar : ProgressBar = $HealthBar
@onready var upgrade_counter : UpgradeCounter = $UpgradeCounter

@export var rocket : PackedScene;

var rocket_power : float = 1;


var rocketCooldown : float = 1.0;
var uBootDir : Vector2 = Vector2.ZERO;

var _last_laser_rid : RID
var _last_laser_rid_change_time : int

var is_dead : bool = false

func _ready() -> void:
	propellerAnimation.play("spin")
	propellerAnimation.speed_scale = 0.1
	animationPlayer.play("idle")
	health_bar.set_max_health(health)

func spawn_rocket():
	var rocket_instance = rocket.instantiate()
	rocket_instance.global_position = torpedo_rampe.global_position
	rocket_instance.get_child(0).linear_velocity += self.linear_velocity
	rocket_instance.get_child(0).rocket_power = rocket_power
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
	
	if rocketCooldown <= 0:
		rocketCooldown -= delta
		
	if Input.is_action_just_pressed("mouse_click") && rocketCooldown <= 0:
		spawn_rocket()
		rocketCooldown = 3.0
	
	var speed = self.linear_velocity.length()
	var t = clamp(speed/ 30.0, 1.0, 3.0)
	propellerAnimation.speed_scale = pow(t, 2)
	%UI.update_progress_bar(position.y)


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
