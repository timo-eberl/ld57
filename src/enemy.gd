extends RigidBody2D
class_name Enemy

@export var enemy_stats : EnemyStats

@onready var sprite = $Texture

func _ready():
	sprite.flip_v = true

func _process(delta):
	if not enemy_stats.asleep:
		var direction : Vector2 = (%Player.global_position - global_position).normalized()
		if direction.x < 0.0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		sprite.look_at(direction)
		apply_force(direction * enemy_stats.acell)

func _apply_damage():
	pass

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > enemy_stats.max_speed:
		self.linear_velocity = self.linear_velocity.normalized() * enemy_stats.max_speed;
	
	self.linear_velocity = self.linear_velocity * 0.95;
	
	pass;

func _on_attack_area_body_entered(body):
	if body.name == "Player":
		body.apply_hit(enemy_stats.damage)
