class_name UpgradeOrb
extends RigidBody2D

@export var type : UpgradeCounter.Weapon
@export var max_speed := 50.0
@export var accel := 500.0

@onready var player : Player = get_tree().root.get_child(0).find_child("Player")

func _on_body_entered(body: Node) -> void:
	if body is Player:
		var upgrade_counter : UpgradeCounter = body.get_node("UpgradeCounter")
		upgrade_counter.progress(type)
		self.queue_free()

func _physics_process(delta: float) -> void:
	# move towards player
	if self.linear_velocity.length() < max_speed:
		var direction : Vector2 = (player.global_position - global_position).normalized()
		apply_force(direction * accel)
