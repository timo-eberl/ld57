extends Enemy

func _ready():
	sleeping = true
	
	_awake_enemy()
	
	animationPlayer.play("idle")

func _on_attack_area_body_entered(body):
	_area_entered(body)

func _on_attack_area_body_exited(body):
	_area_left(body)
