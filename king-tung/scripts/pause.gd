# pause_menu.gd — Pause overlay
# Instanced into the level scene and hidden until the player pauses.
# Process Mode is Always so its buttons still respond while the tree is frozen.
extends Control

const MAIN_MENU := "res://scenes/main_menu.tscn"
const GROUP_ENEMY := "enemy"

@export var resume_button: Button
@export var main_menu_button: Button


func _ready() -> void:
	# Connected in code rather than through the editor so the wiring
	# is visible in the script itself.
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


# GUI event handler — runs when Resume is pressed.
# Unfreezes the tree and hides this overlay, returning the player to play.
func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false
	clear_enemy_attacks()


# GUI event handler — runs when Exit to Menu is pressed.
func _on_main_menu_pressed() -> void:
	# Unpause before leaving, or the menu scene loads frozen
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)


# Clears every enemy's attack state on resume, so none are left frozen
# mid-swing with their damage hitbox still enabled.
func clear_enemy_attacks() -> void:
	for enemy in get_tree().get_nodes_in_group(GROUP_ENEMY):
		enemy.cancel_attack()
