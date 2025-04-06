extends ProgressBar

@export var max_health := 100.0
var current_health := 100.0

@export var visibility_duration := 5.0
var visibility_timer := 0.0

func _process(delta):
	if visible:
		if visibility_timer >= visibility_duration:
			visible = false
		
		visibility_timer += delta

func deal_damage(amount):
	value -= amount
	
	if value <= 0.0: value = 0.0
	
	visibility_timer = 0.0
	visible = true
	
func set_max_health(new_value):
	max_value = new_value
	value = new_value
	current_health = new_value
