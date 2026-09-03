# level_one.gd — Level root
# Shows the How to Play dialog on open and freezes gameplay until dismissed.
extends Node2D

@export var pause_menu: Control

func _ready() -> void:
	# Order is deliberate:
	#   1. Show the dialog while the game still runs, so it appears.
	#   2. Connect confirmed before the player can click OK.
	#   3. Pause last — the dialog's Process Mode is "Always", so it
	#      stays interactive while everything else is frozen.
	$HowToPlay.popup_centered()
	$HowToPlay.confirmed.connect(_on_how_to_play_closed)
	get_tree().paused = true

func _on_how_to_play_closed() -> void:
	# GUI event handler — fired by the dialog's confirmed signal when
	# the player presses OK. Unfreezes the game so play can begin.
	get_tree().paused = false
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not $HowToPlay.visible:
		toggle_pause()

# Flips the paused state and shows or hides the pause menu to match.
func toggle_pause() -> void:
	var is_paused: bool = not get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
