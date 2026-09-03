# baby_shark.gd — Enemy
# Waits until the player enters its detection range, then chases them.
# Attacks on a 3-second cooldown once they're in attack range; the damage
# hitbox is enabled only during frames 1–2 of the attack animation.
# Needs three Area2D children (contact, attack range, detection range),
# a Timer, an AnimatedSprite2D and a ProgressBar.
extends CharacterBody2D

# --- Movement ---
const SPEED = 200

# --- Groups ---
const GROUP_PLAYER := "player"
const PROP_DISABLED := "disabled"

# --- Health Warning ---
const LOW_HEALTH_WARNING := 40.0

# --- Animations ---
const ANIM_ATTACK := "attack"
const ANIM_WALK := "walk"
const ANIM_IDLE := "idle"
const HITBOX_ON_FRAME := 1
const HITBOX_OFF_FRAME := 3

# Variables
var health : int 
var damage : int = 1	  # Health removed from the player per contact
var gravity : float = 900
var player_detected: bool = false
var player_in_range: bool = false
var can_attack: bool = true
var is_attacking: bool = false

# Exported so tougher variants are an inspector change, not a new script
@export var max_health : int = 3
@export var player: CharacterBody2D
@export var health_ui: ProgressBar
@export var sprite: AnimatedSprite2D
@export var center_pivot: Node2D
@export var damage_hitbox: CollisionShape2D
@export var attack_cooldown: Timer

func _ready() -> void:
	# health starts full. Set here rather than at declaration because
	# max_health is exported and isn't available until the node is ready.
	health = max_health
	health_ui.max_value = health
	health_ui.value = health

## Plays the attack animation and starts the cooldown.
## Called from _physics_process when the player is in range.
func attack() -> void:
	can_attack = false
	is_attacking = true
	sprite.play(ANIM_ATTACK)
	attack_cooldown.start()

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
			sprite.play(ANIM_WALK)
		
		var facing := -signf(direction.x)
		
		if direction.x != 0 and center_pivot.scale.x != facing:
			center_pivot.scale.x = facing
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)	# No target — decelerate smoothly instead of stopping dead
		if not is_attacking:
			sprite.play(ANIM_IDLE)
			
	# Attack if the player is in range and the cooldown has elapsed
	if player_in_range and can_attack:
		attack()
		
	# 3. Last — move_and_slide() acts on the final velocity.
	move_and_slide()
		
		
# Reduces health and frees this enemy once dead.
# Called by the player's hitbox, not by this script.
# amount — damage supplied by the attacker, so different weapons need no change here.
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_ui.value = health
	if get_health_percent() < LOW_HEALTH_WARNING:
		health_ui.modulate = Color.RED
	if health <= 0:
		queue_free()	  # Removes this enemy from the scene tree


# Returns current health as a percentage, 0.0 to 100.0.
# The float() casts are required: int / int truncates, so 1 / 3 would be 0.
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return (float(health) / float(max_health)) * 100.0

# Signal handler — fired by the child Area2D when a body enters it.
# The group check stops the enemy damaging walls or other enemies.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group(GROUP_PLAYER):
		body.take_damage(damage)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group(GROUP_PLAYER):
		player_in_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group(GROUP_PLAYER):
		player_in_range = false
		if is_attacking:
			is_attacking = false
			damage_hitbox.set_deferred(PROP_DISABLED, true)
			sprite.play(ANIM_WALK)


func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group(GROUP_PLAYER):
		player_detected = true


func _on_detection_range_body_exited(body: Node2D) -> void:
	if body.is_in_group(GROUP_PLAYER):
		player_detected = false


func _on_animated_sprite_2d_frame_changed() -> void:
	# Only the attack animation drives the hitbox
	if sprite.animation != ANIM_ATTACK:
		return
	if sprite.frame == HITBOX_ON_FRAME:
		damage_hitbox.set_deferred(PROP_DISABLED, false)
	elif sprite.frame == HITBOX_OFF_FRAME:
		damage_hitbox.set_deferred(PROP_DISABLED, true)


func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
	damage_hitbox.set_deferred(PROP_DISABLED, true)


func _on_attack_cooldown_timeout() -> void:
	can_attack = true
