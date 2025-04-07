extends Control

@onready var progress_bar : VSlider = $MarginContainer/ProgressBar
@onready var rocket_orb_amount : Label = $MarginContainer2/VBoxContainer/RocketOrbIcon/MarginContainer/Label
@onready var laser_orb_amount : Label = $MarginContainer2/VBoxContainer/LaserOrbIcon/MarginContainer/Label

@export var upmost_progress := 300.0
@export var lowest_possible := 15450.0

func _ready():
	progress_bar.min_value = upmost_progress
	progress_bar.max_value = lowest_possible
	
func update_progress_bar(new_y):
	progress_bar.value = new_y 
	
func update_rocket_orb_count(new_amount):
	rocket_orb_amount.text = str(new_amount)

func update_laser_orb_count(new_amount):
	laser_orb_amount.text = str(new_amount)
	
