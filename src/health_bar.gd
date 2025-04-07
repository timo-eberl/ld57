extends ProgressBar

var max_health := 100.0
var current_health := 100.0

@export var visibility_duration := 5.0
var visibility_timer := 0.0

var fade_out := false
var fade_out_progress := 0.0

func _ready():
	set_self_modulate(Color(1.0, 1.0, 1.0, 0.0))

func _process(delta):
	if fade_out:
		if fade_out_progress >= 1.0:
			fade_out = false
			fade_out_progress = 0.0
		else:
			var current_fade = lerp(0.0, 1.0, fade_out_progress)
			set_self_modulate(Color(1.0, 1.0, 1.0, 1.0 - current_fade))
	
		fade_out_progress += delta
	if self_modulate == Color(1.0, 1.0, 1.0, 1.0):
		if visibility_timer >= visibility_duration:
			fade_out = true
		
		visibility_timer += delta

func deal_damage(amount):
	set_self_modulate(Color(1.0, 1.0, 1.0, 1.0))
	fade_out = false
	fade_out_progress = 0.0
	
	value -= amount
	
	if value <= 0.0: value = 0.0
	
	visibility_timer = 0.0
	
func set_max_health(new_value):
	max_value = new_value
	value = new_value
	current_health = new_value
