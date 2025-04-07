class_name UpgradeCounter
extends Node2D

@export var points_for_upgrade := 10

var laser_level := 0
var laser_level_progress := 0

var rocket_level := 0
var rocket_level_progress := 0

enum Weapon {
	LASER, ROCKET
}

func progress(weapon : Weapon):
	if weapon == Weapon.LASER:
		laser_level_progress += 1
		if laser_level_progress >= points_for_upgrade:
			laser_level += 1
			laser_level_progress -= points_for_upgrade
	if weapon == Weapon.ROCKET:
		rocket_level_progress += 1
		if rocket_level_progress >= points_for_upgrade:
			rocket_level += 1
			rocket_level_progress -= points_for_upgrade
