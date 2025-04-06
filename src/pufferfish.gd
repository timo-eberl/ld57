extends Enemy

@export var unpuffed : CompressedTexture2D
@export var puffed : CompressedTexture2D

var puff : bool = false
var hit_player :bool = false
var shrink : bool = false
var puff_done : bool = false

var default_scale = 0.3
var puffed_scale = 1.0
var puff_speed = .5
var unpuff_speed = .5

var puff_progress = 0.0

func _process(delta):
	if puff:
		var puff_amount = lerp(default_scale, puffed_scale, puff_progress / puff_speed)
		
		sprite.scale = Vector2(puff_amount, puff_amount)
		
		if puff_progress >= puff_speed:
			puff = false
			hit_player = true
			puff_progress = 0.0
		
		puff_progress += delta
	
	if hit_player:
		if player_in_area:
			%Player.apply_hit(enemy_stats.damage)
		hit_player = false;
		shrink = true

	if shrink:
		hit_timer = 0.0
		
		var unpuff_amount = lerp(puffed_scale, default_scale, puff_progress / unpuff_speed)
		
		sprite.scale = Vector2(unpuff_amount, unpuff_amount)
		if puff_progress >= puff_speed:
			shrink = false
			puff_done = true
			puff_progress = 0.0
		hit_timer = 0.0
		
		puff_progress += delta
	
	if puff_done:
		sprite.texture = unpuffed
		puff_done = false
	
	if player_in_area:
		if hit_timer >= enemy_stats.hit_cooldown:
			puff = true
			sprite.texture = puffed
		hit_timer += delta
		
	if enemy_stats.health <= 0:
		_kill_enemy()

func _physics_process(delta):
	if not enemy_stats.asleep or player_in_area:
		_move()

func _area_entered(body):
	if body.name == "Player" and not enemy_stats.asleep:
		player_in_area = true

func _area_left(body):
	if body.name == "Player" and not enemy_stats.asleep:
		player_in_area = false
		hit_timer = 0.0

func _on_area_2d_body_entered(body):
	_area_entered(body)


func _on_area_2d_body_exited(body):
	_area_left(body)
	hit_timer = 0.0
