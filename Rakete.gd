extends RigidBody2D

@onready var rocketSprite : Sprite2D = $Rakete;
func _process(delta):
	rocketSprite.look_at(get_global_mouse_position())
	self.apply_force(get_global_mouse_position() - global_position)
	pass;

func _integrate_forces(state: PhysicsDirectBodyState2D):
	#self.linear_velocity = (Vector2.RIGHT * 100.0).rotated(get_angle_to(get_global_mouse_position()))
	
	
	
	pass;
