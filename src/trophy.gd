extends Node2D


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		get_tree().root.get_node("World/Player/CanvasLayer/UI/").enable_win_screen()
		get_tree().root.get_node("World/Player/").won = true
