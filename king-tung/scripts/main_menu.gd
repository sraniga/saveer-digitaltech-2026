# main_menu.gd — Title screen
# Connects the two menu buttons to their handlers.
extends Control

const LEVEL_ONE := "res://scenes/level_one.tscn"

@export var play_button: Button
@export var quit_button: Button

func _ready() -> void:
	# Connected in code rather than through the editor so the wiring
	# is visible in the script itself.
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	
# GUI event handler — runs when Play is pressed. Replaces the menu
# scene entirely; the menu node is freed automatically.
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_ONE)
	
	
# GUI event handler — runs when Quit is pressed. Closes the window.
func _on_quit_pressed() -> void:
	get_tree().quit()
