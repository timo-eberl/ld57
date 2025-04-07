extends Control

@onready var progress_bar : VSlider = $MarginContainer/ProgressBar
@onready var rocket_orb_amount : Label = $MarginContainer2/VBoxContainer/RocketOrbIcon/MarginContainer/Label
@onready var laser_orb_amount : Label = $MarginContainer2/VBoxContainer/LaserOrbIcon/MarginContainer/Label
@onready var death_screen : Control = $DeathScreen

@export var upmost_progress := 300.0
@export var lowest_possible := 15450.0

var death_screen_fade := false
var fade_timer := 0.0
var death_transition_done := false

func _ready():
	progress_bar.min_value = upmost_progress
	progress_bar.max_value = lowest_possible

func _process(delta):
	if death_screen_fade:
		if fade_timer >= 1.0:
			death_transition_done = true
		else:
			var fade_progress = lerp(0.0, 1.0, fade_timer)
			death_screen.set_modulate(Color(1.0, 1.0, 1.0, fade_progress))
			fade_timer += delta

func _input(event):
	if event is InputEventKey and death_transition_done:
			get_tree().reload_current_scene()
		

func update_progress_bar(new_y):
	progress_bar.value = new_y 
	
func update_rocket_orb_count(new_amount):
	rocket_orb_amount.text = str(new_amount)

func update_laser_orb_count(new_amount):
	laser_orb_amount.text = str(new_amount)

func set_game_over():
	#death_screen.visible = true
	death_screen_fade = true
	
