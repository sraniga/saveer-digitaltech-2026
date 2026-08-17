extends Control


func _ready() -> void:
	# Connected in code rather than through the editor so the wiring
	# is visible in the script itself.
	$Play.pressed.connect(_on_play_pressed)
	$Quit.pressed.connect(_on_quit_pressed)
	
# GUI event handler — runs when Play is pressed. Replaces the menu
# scene entirely; the menu node is freed automatically.
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_one.tscn")
	
# GUI event handler — runs when Quit is pressed. Closes the window.
func _on_quit_pressed() -> void:
	get_tree().quit()
