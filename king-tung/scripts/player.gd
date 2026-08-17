# player.gd — Player character
# Keyboard movement, jumping, bat swing attack, and taking damage.
# Reloads the level on death. Node references are set in the inspector.

extends CharacterBody2D

# --- Movement tuning ---
const SPEED = 300
const JUMP_VELOCITY = -500
# Negative because Godot's 2D Y axis points down

# --- Combat ---
var health: int = 10
var basic_damage: int = 1
var boss_damage: int = 3

# --- Node references (assigned in the inspector) ---
@export var animation: AnimationPlayer
@export var health_ui: ProgressBar
@export var sprite: Node
@export var center_pivot: Node2D


func _ready() -> void:
	#max_value is set first because value is clamped to it
	health_ui.max_value = health
	health_ui.value = health


func _physics_process(delta: float) -> void:
	# 1. Gravity, read from project settings rather than hardcoded
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 2. Jump. The is_on_floor() check is what prevents mid-air jumping.
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# 3. Horizontal input. get_axis() returns -1.0 left, 1.0 right, 0.0 for
	#    neither, so it doubles as the "is the player moving?" test below.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite.play("walk")
		# Scale the pivot rather than flipping the sprite, so the bat —
		# a child of the pivot — swings on the correct side of the body.
		if not center_pivot.scale.x == direction:
			center_pivot.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.animation = "idle"
		
	# 4. Attack. just_pressed stops a held key retriggering every frame.
	if Input.is_action_just_pressed("swing_bat"):
		animation.play("swing")
		
	# 5. Last, once every change to velocity above has been applied.
	move_and_slide()
	
# Reduces player health and restarts the level on death.
func take_damage() -> void:
	if health > 1:
		health -= 1
		health_ui.value = health
	else:
		# Deferred because this runs during collision processing — reloading
		# immediately would free nodes the physics engine is still using.
		get_tree().call_deferred("reload_current_scene")

# Signal handler — fired by the bat's Area2D when it overlaps a body.
# The group check means only enemies take damage, not walls or floor.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(basic_damage)
		 
