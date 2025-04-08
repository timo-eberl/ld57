extends Control

@onready var progress_bar : VSlider = $MarginContainer/ProgressBar
@onready var rocket_orb_level : Label = $MarginContainer2/VBoxContainer/RocketOrb/HBoxContainer/RocketOrbIcon/MarginContainer/Label
@onready var laser_orb_level : Label = $MarginContainer2/VBoxContainer/LaserOrb/HBoxContainer/LaserOrbIcon/MarginContainer/Label
@onready var rocket_orb_progress : ProgressBar = $MarginContainer2/VBoxContainer/RocketOrb/HBoxContainer/MarginContainer/ProgressBar
@onready var laser_orb_progress : ProgressBar = $MarginContainer2/VBoxContainer/LaserOrb/HBoxContainer/MarginContainer/ProgressBar
@onready var death_screen : Control = $DeathScreen
@onready var win_screen : Control = $WinScreen
@onready var win_lable : Label = $WinScreen/MarginContainer/VBoxContainer/Label2


@export var upmost_progress := 300.0
@export var lowest_possible := 15450.0

var total_time : float = 0

var death_screen_fade := false
var fade_timer := 0.0
var death_transition_done := false

var win_screen_fade := false
var win_transition_done := false

func _ready():
	progress_bar.min_value = upmost_progress
	progress_bar.max_value = lowest_possible
	total_time = 0

func _process(delta):
	total_time += delta
	
	if death_screen_fade:
		if fade_timer >= 1.0:
			death_transition_done = true
		else:
			var fade_progress = lerp(0.0, 1.0, fade_timer)
			death_screen.set_modulate(Color(1.0, 1.0, 1.0, fade_progress))
			fade_timer += delta
	
	if win_screen_fade:
		if fade_timer >= 1.0:
			win_transition_done = true
		else:
			var fade_progress = lerp(0.0, 1.0, fade_timer)
			win_screen.set_modulate(Color(1.0, 1.0, 1.0, fade_progress))
			fade_timer += delta

#func _input(event):
	#if event is InputEventKey:
		#if death_transition_done:
			#get_tree().reload_current_scene()
		

func update_progress_bar(new_y):
	progress_bar.value = new_y 

func update_rocket_level(new_level):
	rocket_orb_level.text = str(new_level)

func update_laser_level(new_level):
	laser_orb_level.text = str(new_level)

func update_rocket_level_progress(new_value, max_value):
	rocket_orb_progress.value = new_value
	rocket_orb_progress.max_value = max_value

func update_laser_level_progress(new_value, max_value):
	laser_orb_progress.value = new_value
	laser_orb_progress.max_value = max_value

func set_game_over():
	death_screen_fade = true

func enable_win_screen():
	win_screen_fade = true
	win_lable.text = "Thank you for playing :) \n Time " + str(total_time).pad_decimals(2)
	
