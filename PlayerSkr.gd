extends RigidBody2D

@export var movementInput : Vector2;
@export var maxSpeed : float = 50.0;
@export var acell : float = 100.0;


@onready var uBootSprite : Sprite2D = $Submarine;
@onready var laserLine : Line2D = $Submarine/LaserPunkt/Line2D;

var rocketCooldown : float = 100.0;
var uBootDir : Vector2 = Vector2.ZERO;

func _ready() -> void:
	laserLine.add_point(Vector2.ZERO)
	laserLine.add_point(Vector2.ZERO)
	pass;


func _process(delta):
	movementInput = Vector2.ZERO;
	
	if Input.is_action_pressed("Horizontal_plus"):
		movementInput.x += 1
	if Input.is_action_pressed("Horizontal_minus"):
		movementInput.x -= 1
	if Input.is_action_pressed("Vertical_minus"):
		movementInput.y += 1
	if Input.is_action_pressed("Vertical_plus"):
		movementInput.y -= 1
	
	if movementInput.length() > 1.0:
		movementInput = movementInput.normalized();
	
	if rocketCooldown > 0:
		rocketCooldown -= delta;
	
	laserLine.visible = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT);
	
	var lookPos = get_global_mouse_position();
	var myPos = self.global_position;
	
	var targetVec = lookPos - myPos;
	
	if myPos.x < lookPos.x:
		targetVec = -targetVec
		uBootSprite.flip_h = true
	else:
		uBootSprite.flip_h = false
	
	uBootDir = lerp(uBootDir, targetVec, delta * 2.0);
	
	#targetVec.x = targetVec.x * 2.5
	
	uBootSprite.look_at(myPos - uBootDir)
	
	#print(lookPos - myPos);
	
	self.apply_force(movementInput * acell);
	#laserLine.set_point_position(0, self.global_position)
	laserLine.set_point_position(1, laserLine.to_local(get_global_mouse_position()) * 100.0)
	
	
	
	
func _integrate_forces(state: PhysicsDirectBodyState2D):
	if self.linear_velocity.length() > maxSpeed:
		self.linear_velocity = self.linear_velocity.normalized() * maxSpeed;
	
	self.linear_velocity = self.linear_velocity * 0.95;
	
	pass;
