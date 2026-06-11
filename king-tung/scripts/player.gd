extends CharacterBody2D

const SPEED = 300
const JUMP_VELOCITY = -500

@export var animation: AnimationPlayer


func _physics_process(delta: float) -> void:
	#add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
