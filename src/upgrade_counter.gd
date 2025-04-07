class_name UpgradeCounter
extends Node2D

@export var points_for_upgrade := 1
@onready var laser_parent : Node2D = $"../Submarine/LaserSpriteParent3"


var laser_level := 0
var laser_level_progress := 0

var rocket_level := 0
var rocket_level_progress := 0

enum Weapon {
	LASER, ROCKET
}

func on_laser_levelup():
	laser_level += 1
	laser_level_progress -= points_for_upgrade
	
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
		%UI.update_laser_orb_count(laser_level_progress)
		if laser_level_progress >= points_for_upgrade:
			on_laser_levelup()
			
			
			
	if weapon == Weapon.ROCKET:
		rocket_level_progress += 1
		%UI.update_rocket_orb_count(rocket_level_progress)
		if rocket_level_progress >= points_for_upgrade:
			rocket_level += 1
			rocket_level_progress -= points_for_upgrade
