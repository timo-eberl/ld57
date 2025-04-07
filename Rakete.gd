extends RigidBody2D

@onready var rocketSprite : Sprite2D = $Rakete;


func _process(_delta):
	rocketSprite.look_at(get_global_mouse_position())
	self.apply_force(get_global_mouse_position() - global_position)
	pass;

func _integrate_forces(_state: PhysicsDirectBodyState2D):
	#self.linear_velocity = (Vector2.RIGHT * 100.0).rotated(get_angle_to(get_global_mouse_position()))
	pass;



func _on_body_entered(_body: Node) -> void:
	var strength = max(128, min(linear_velocity.length() / 10.0, 300))
	
	
	var obstacles : Map = get_tree().root.get_child(0).get_node("ObstaclesTiles")
	obstacles.explosion(global_position, strength, 500)
	self.get_parent().queue_free()
	pass # Replace with function body.
