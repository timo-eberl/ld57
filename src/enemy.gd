extends RigidBody2D
class_name Enemy

@export var enemy_stats : EnemyStats

@onready var sprite = $Texture

var player_in_area : bool = false

var hit_timer = 0.0

func _ready():
	sprite.flip_v = true

func _process(delta):
	if player_in_area:
		if hit_timer >= enemy_stats.hit_cooldown:
			%Player.apply_hit(enemy_stats.damage)
			hit_timer = 0.0
		hit_timer += delta
	if enemy_stats.health <= 0.0:
		queue_free()

func _physics_process(_delta):
	if not enemy_stats.asleep:
		var direction : Vector2 = (%Player.global_position - global_position).normalized()
		if direction.x > 0.0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		sprite.look_at(direction)
		apply_force(direction * enemy_stats.acell)

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > enemy_stats.max_speed:
		self.linear_velocity = self.linear_velocity.normalized() * enemy_stats.max_speed;
	
	self.linear_velocity = self.linear_velocity * 0.95;
	
	pass;

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		body.apply_hit(enemy_stats.damage)
		player_in_area = true


func _on_attack_area_body_exited(body):
	if body.name == "Player":
		player_in_area = false
		hit_timer = 0.0
