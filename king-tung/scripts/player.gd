extends CharacterBody2D

const SPEED = 300
const JUMP_VELOCITY = -300

func _physics_process(delta: float) -> void:
	#add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
