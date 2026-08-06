extends Node2D

func _ready() -> void:
	#Popup screen when level first starts
	$HowToPlay.popup_centered()
	$HowToPlay.confirmed.connect(_on_how_to_play_closed)
	get_tree().paused = true

func _on_how_to_play_closed() -> void:
	get_tree().paused = false
