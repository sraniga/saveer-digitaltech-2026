# baby_shark.gd — Enemy
# Chases the player horizontally and damages them on contact.
# Killed by the player's bat. Needs a child Area2D hitbox and a ProgressBar.
extends CharacterBody2D

const SPEED = 200

var health : int 
var damage : int = 1	# Health removed from the player per contact
var gravity : float = 900
var player_detected: bool = false
var player_in_range: bool = false
var can_attack: bool = true
var is_attacking: bool = false
var attack_target: Node2D = null

@export var max_health : int = 3	# Exported so tougher variants are an inspector change, not a new script
@export var player: CharacterBody2D
@export var health_ui: ProgressBar
@export var sprite: Node
@export var center_pivot: Node2D
@export var damage_hitbox: CollisionShape2D

func _ready() -> void:
	# Set here, not at declaration — exported values are applied after
	# member defaults are evaluated, so it would always use the default.
	health = max_health
	health_ui.max_value = health
	health_ui.value = health

# Plays the attack animation and starts the cooldown.
# Called from _physics_process when the player is in range.
func attack() -> void:
	print("attack called")
	can_attack = false
	is_attacking = true
	sprite.play("attack")
	print("now playing: ", sprite.animation)
	$AttackCooldown.start()

func _physics_process(delta: float) -> void:

	# 1. Gravity — keeps the enemy grounded and lets it fall off ledges.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# 2. Steering. direction_to() returns a normalised Vector2, so using
	#    only x gives left/right chase without any vertical flying.
	if player != null and player_detected:	# Chase target; null means "stay put"
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity.x = direction.x * SPEED
		if not is_attacking:
			sprite.play("walk")
		
		var facing := -signf(direction.x)
		
		if direction.x != 0 and center_pivot.scale.x != facing:
			center_pivot.scale.x = facing
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	# No target — decelerate smoothly instead of stopping dead
		if not is_attacking:
			sprite.play("idle")
			
	# Attack if the player is in range and the cooldown has elapsed
	if player_in_range and can_attack:
		attack()
		
	# 3. Last — move_and_slide() acts on the final velocity.
	print(velocity.x)
	move_and_slide()
		
		
# Reduces health and frees this enemy once dead.
# Called by the player's hitbox, not by this script.
#   amount — damage supplied by the attacker, so different weapons
#            need no change here.
func take_damage(amount: int) -> void:
	health -= amount
	health_ui.value = health
	if health <= 0:
		queue_free()	# Removes this enemy from the scene tree

# Uses the percentage rather than a raw value so the threshold stays
# correct whatever max_health is set to.
func get_health_percent() -> float:
	return (float(health) / float(max_health)) * 100.0

# Signal handler — fired by the child Area2D when a body enters it.
# The group check stops the enemy damaging walls or other enemies.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		attack_target = body


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		attack_target = null
		if is_attacking:
			is_attacking = false
			damage_hitbox.set_deferred("disabled", true)
			sprite.play("walk")


func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = true


func _on_detection_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = false


func _on_animated_sprite_2d_frame_changed() -> void:
	# Only the attack animation drives the hitbox
	if sprite.animation != "attack":
		return
	if sprite.frame == 1:
		damage_hitbox.set_deferred("disabled", false)
	elif sprite.frame == 3:
		damage_hitbox.set_deferred("disabled", true)


func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
	damage_hitbox.set_deferred("disabled", true)


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
