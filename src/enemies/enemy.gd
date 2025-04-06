extends RigidBody2D
class_name Enemy

@export var enemy_stats : EnemyStats

@onready var health_bar : ProgressBar = $HealthBar

@onready var sprites : Node2D = $Texture
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

var player_in_area : bool = false

var is_dead : bool = false

var hit_timer = 0.0

var fade_out_progress := 0.0

func _ready():
	sleeping = true
	health_bar.set_max_health(enemy_stats.health)
	animationPlayer.play("idle")

	_awake_enemy()

func _process(delta):
	if is_dead:
		if fade_out_progress >= 1.0:
			queue_free()
		else:
			var current_fade = lerp(0.0, 1.0, fade_out_progress)
			sprites.get_node("DeathSprite").set_self_modulate(Color(1.0, 1.0, 1.0, 1.0 - current_fade))
	
		fade_out_progress += delta
	
	if not is_dead:
		if player_in_area:
			if hit_timer >= enemy_stats.hit_cooldown:
				%Player.apply_hit(enemy_stats.damage)
				hit_timer = 0.0
			hit_timer += delta
	
		if enemy_stats.health <= 0:
			_kill_enemy()
		
		if not animationPlayer.is_playing():
			animationPlayer.play("idle")

func _physics_process(delta):
	if not enemy_stats.asleep and not is_dead:
		_move()

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > enemy_stats.max_speed:
		self.linear_velocity = self.linear_velocity.normalized() * enemy_stats.max_speed;
	
	self.linear_velocity = self.linear_velocity * 0.95;

func _move():
	if !is_instance_valid(%Player):
		return
	var direction : Vector2 = (%Player.global_position - global_position).normalized()
	if direction.x < 0.0:
		sprites.scale.x = -abs(sprites.scale.x)
	else:
		sprites.scale.x = abs(sprites.scale.x)
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

func play_hit_animation():
	if not is_dead:
		animationPlayer.play("hit")

func take_damage(damage):
	health_bar.deal_damage(damage)
	
	enemy_stats.health -= damage
	play_hit_animation()

func _kill_enemy():
	if not is_dead:
		animationPlayer.play("death")
		health_bar.fade_out = true
		collision_layer = 0
		is_dead = true
