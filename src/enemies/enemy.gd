extends RigidBody2D
class_name Enemy

@export var enemy_stats : EnemyStats
# %Player doesn't work if instantiated dynamically
@onready var player : Player = get_tree().root.get_child(0).find_child("Player")
@onready var map : Map = get_tree().root.get_child(0).find_child("ObstaclesTiles")

@onready var health_bar : ProgressBar = $HealthBar

@export var spawn_on_die : PackedScene

@onready var sprites : Node2D = $Texture
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@onready var navigation : NavigationAgent2D

var player_in_area : bool = false
var is_dead : bool = false
var is_asleep : bool = true

# enemy damage deal timer
var damage_timer = 0.0

# damage take visual timer
var hit_timer = 0.0
var damage_taken : bool = false
@export var fade_out_duration := 0.5
@export var hit_modulation_color : Color

var death_fade_out_progress := 0.0
var health := 0.0

#var hit_timer

func _ready():
	navigation = get_node("NavigationAgent2D")
	navigation.target_position = player.global_position
	
	
	sleeping = true
	freeze = true
	health = enemy_stats.health
	health_bar.set_max_health(health)
	animationPlayer.play("asleep")

func spawn_scene():
	var instance : Node2D = spawn_on_die.instantiate()
	instance.global_position = self.global_position
	get_tree().root.get_child(0).add_child(instance)

func _process(delta):
	if is_dead:
		if death_fade_out_progress >= 1.0:
			queue_free()
		else:
			var current_fade = lerp(0.0, 1.0, death_fade_out_progress)
			sprites.get_node("DeathSprite").set_self_modulate(Color(1.0, 1.0, 1.0, 1.0 - current_fade))
	
		death_fade_out_progress += delta
	
	if not is_dead:
		if damage_taken:
			if hit_timer <= fade_out_duration:
				var modulate_color = lerp(hit_modulation_color, Color.WHITE, hit_timer / fade_out_duration)
				for sprite in sprites.get_children():
					sprite.set_self_modulate(modulate_color)
			else:
				damage_taken = false
				hit_timer = 0.0
			hit_timer += delta
		if player_in_area:
			if damage_timer >= enemy_stats.hit_cooldown:
				player.apply_hit(enemy_stats.damage)
				damage_timer = 0.0
			damage_timer += delta
	
		if health <= 0:
			_kill_enemy()
		
		if not animationPlayer.is_playing():
			animationPlayer.play("idle")

func awake_if_water():
	if is_asleep and not is_dead:
		# enemy positon to coordinates on tilemap
		var map_coords := map.local_to_map(map.to_local(self.global_position))
		if map.is_water(map_coords):
			_awake_enemy()

func _physics_process(_delta):
	awake_if_water()
	if not is_asleep and not is_dead:
		_move()

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > enemy_stats.max_speed:
		self.linear_velocity = self.linear_velocity.normalized() * enemy_stats.max_speed;
	
	self.linear_velocity = self.linear_velocity * 0.95;

func _move():
	navigation.target_position = player.global_position
	var targetPos = navigation.get_next_path_position()
	
	var direction : Vector2 = (targetPos - global_position).normalized()
	if direction.x < 0.0:
		sprites.scale.x = -abs(sprites.scale.x)
	else:
		sprites.scale.x = abs(sprites.scale.x)
	#sprite.look_at(direction)
	if not player_in_area:
		apply_force(direction * enemy_stats.acell)

func _area_entered(body):
	if body.name == "Player" and not is_asleep and not is_dead:
		body.apply_hit(enemy_stats.damage)
		player_in_area = true

func _area_left(body):
	if body.name == "Player" and not is_asleep:
		player_in_area = false
		damage_timer = 0.0

func _awake_enemy():
	animationPlayer.play("idle")
	is_asleep = false
	sleeping = false
	freeze = false

func play_hit_animation():
	if not is_dead:
		for sprite in sprites.get_children():
			sprite.set_self_modulate(hit_modulation_color)
		damage_taken = true
		hit_timer = 0.0
		#animationPlayer.play("hit")

func take_damage(damage):
	var damage_multiplier := remap(global_position.y, 0, 12800, 1.0, 0.3)
	damage_multiplier = clampf(damage_multiplier, 0.3, 1)
	damage *= damage_multiplier
	health_bar.deal_damage(damage)
	
	health -= damage
	play_hit_animation()

func _kill_enemy():
	if not is_dead:
		animationPlayer.play("death")
		health_bar.fade_out = true
		collision_layer = 0
		is_dead = true
		spawn_scene()
