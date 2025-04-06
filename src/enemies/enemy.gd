extends RigidBody2D
class_name Enemy

@export var enemy_stats : EnemyStats

@onready var sprite = $Texture

var player_in_area : bool = false

var hit_timer = 0.0

func _ready():
	sleeping = true
	
	_awake_enemy()

func _process(delta):
	if player_in_area:
		if hit_timer >= enemy_stats.hit_cooldown:
			%Player.apply_hit(enemy_stats.damage)
			hit_timer = 0.0
		hit_timer += delta
		
	if enemy_stats.health <= 0:
		_kill_enemy()

func _physics_process(delta):
	if not enemy_stats.asleep:
		_move()

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > enemy_stats.max_speed:
		self.linear_velocity = self.linear_velocity.normalized() * enemy_stats.max_speed;
	
	self.linear_velocity = self.linear_velocity * 0.95;
	
	pass;

func _move():
	var direction : Vector2 = (%Player.global_position - global_position).normalized()
	if direction.x < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	#sprite.look_at(direction)
	if not player_in_area:
		apply_force(direction * enemy_stats.acell)

func _area_entered(body):
	if body.name == "Player" and not enemy_stats.asleep:
		body.apply_hit(enemy_stats.damage)
		player_in_area = true

func _area_left(body):
	if body.name == "Player" and not enemy_stats.asleep:
		player_in_area = false
		hit_timer = 0.0

func _awake_enemy():
	enemy_stats.asleep = false
	sleeping = false

func _kill_enemy():
	queue_free()
