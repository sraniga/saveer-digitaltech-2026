extends CharacterBody2D

const SPEED = 200

var health : int = 3
var damage : int = 1
var gravity : float = 900

@export var player: CharacterBody2D
@export var health_ui: ProgressBar

func _ready() -> void:
	health_ui.max_value = health
	health_ui.value = health


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += gravity * delta
		
	if player != null:
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
		
		
func take_damage() -> void:
	if health > 1:
		health -= 1
		health_ui.value = health
	else:
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()
