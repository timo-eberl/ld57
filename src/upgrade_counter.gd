class_name UpgradeCounter
extends Node2D

#@export var points_for_upgrade_laser := 10
#@export var points_for_upgrade_rocket := 5
@onready var laser_parent : Node2D = $"../Submarine/LaserSpriteParent3"

@export var points_for_upgrade_laser : Array[int]
@export var points_for_upgrade_rocket : Array[int]


var laser_level := 0
var laser_level_progress := 0

var rocket_level := 0
var rocket_level_progress := 0

enum Weapon {
	LASER, ROCKET
}
	
func on_laser_levelup():
	var new_laser = laser_parent.duplicate()
	var dir = 1
	if laser_level % 2 == 0:
		dir = -1;
	
	
	new_laser.laser_offset = laser_level * dir * 4.0;
	laser_parent.add_sibling(new_laser)
	
	pass

func progress(weapon : Weapon):
	if weapon == Weapon.LASER:
		laser_level_progress += 1
		%UI.update_laser_level_progress(laser_level_progress, points_for_upgrade_laser[laser_level])
		if laser_level_progress >= points_for_upgrade_laser[laser_level]:
			laser_level_progress -= points_for_upgrade_laser[laser_level]
			laser_level += 1
			%UI.update_laser_level(laser_level)
			%UI.update_laser_level_progress(laser_level_progress, points_for_upgrade_laser[laser_level])
			on_laser_levelup()
			
			
			
	if weapon == Weapon.ROCKET:
		rocket_level_progress += 1
		%UI.update_rocket_level_progress(rocket_level_progress, points_for_upgrade_rocket[rocket_level])
		if rocket_level_progress >= points_for_upgrade_rocket[rocket_level]:
			rocket_level_progress -= points_for_upgrade_rocket[rocket_level]
			rocket_level += 1
			%UI.update_rocket_level(rocket_level)
			%UI.update_rocket_level_progress(rocket_level_progress, points_for_upgrade_rocket[rocket_level])
