extends Control


func _ready() -> void:
	$Play.pressed.connect(_on_play_pressed)
	$Quit.pressed.connect(_on_quit_pressed)
	
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_one.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
