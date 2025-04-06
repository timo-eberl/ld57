extends Enemy


func _on_attack_area_body_entered(body):
	_area_entered(body)

func _on_attack_area_body_exited(body):
	_area_left(body)
