extends CharacterBody2D

const SPEED = 300

@export var player: CharacterBody2D

func _physics_process(delta: float) -> void:
	if player:
		var direction: Vector2 = global_position.direction_to(player.global_position)
		
		velocity = direction * SPEED
		move_and_slide()
