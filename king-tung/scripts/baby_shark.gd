extends CharacterBody2D

const SPEED = 200

var health : int = 3

@export var player: CharacterBody2D

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player:
		var direction: Vector2 = global_position.direction_to(player.global_position)
		
		velocity = direction * SPEED
		move_and_slide()
		
		
func take_damage() -> void:
	if health > 1:
		health -= 1
	else:
		queue_free()
