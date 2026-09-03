extends Control

func _ready() -> void:
	$Resume.pressed.connect(_on_resume_pressed)
	$MainMenu.pressed.connect(_on_main_menu_pressed)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_main_menu_pressed() -> void:
	# Unpause before leaving, or the menu scene loads frozen
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
