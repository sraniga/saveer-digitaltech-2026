# player.gd — Player character
# Keyboard movement, jumping, bat swing attack, and taking damage.
# Reloads the level on death. Node references are set in the inspector.

extends CharacterBody2D

# --- Movement tuning ---
const SPEED = 300
const JUMP_VELOCITY = -500  # Negative because Godot's 2D Y axis points down

# --- Animations ---
const ANIM_SWING := "swing"
const ANIM_IDLE := "idle"
const ANIM_WALK := "walk"

# --- Actions pressed ---
const UP := "ui_up"
const LEFT := "ui_left"
const RIGHT := "ui_right"
const SPRINT := "sprint"
const SWING_BAT := "swing_bat"

# --- Groups ---
const GROUP_ENEMY := "enemy"

# --- Scenes ---
const RELOAD_SCENE := "reload_current_scene"

# --- Sprinting ---
const SPRINT_MULTIPLIER := 1.8  # Sprint speed as a multiple of SPEED
const STAMINA_DRAIN := 40.0  # Stamina lost per second while sprinting
const STAMINA_REFILL := 30.0  # Stamina regained per second once recharging

var max_stamina: float = 100.0
var stamina: float = 100.0
var can_recharge: bool = false  # True only after the 3s delay has elapsed

# --- Combat ---
var health: int = 10
var basic_damage: int = 1
var boss_damage: int = 3

# --- Node references (assigned in the inspector) ---
@export var animation: AnimationPlayer
@export var health_ui: ProgressBar
@export var sprite: Node
@export var center_pivot: Node2D
@export var stamina_ui: ProgressBar
@export var stamina_recharge: Timer


func _ready() -> void:
	# max_value is set first because value is clamped to it
	health_ui.max_value = health
	health_ui.value = health
	stamina_ui.max_value = max_stamina
	stamina_ui.value = stamina


func _physics_process(delta: float) -> void:
	# 1. Gravity, read from project settings rather than hardcoded
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 2. Jump. The is_on_floor() check is what prevents mid-air jumping.
	if Input.is_action_pressed(UP) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# 3. Horizontal input. get_axis() returns -1.0 left, 1.0 right, 0.0 for
	#    neither, so it doubles as the "is the player moving?" test below.
	var direction := Input.get_axis(LEFT, RIGHT)
	
	# Sprint requires the key held, actual movement, and stamina remaining
	var is_sprinting: bool = (Input.is_action_pressed(SPRINT)
		and direction != 0
		and stamina > 0.0)
	var current_speed: float = SPEED

	if is_sprinting:
		current_speed = SPEED * SPRINT_MULTIPLIER
		stamina = max(stamina - STAMINA_DRAIN * delta, 0.0)
		can_recharge = false
		# start() every frame means the 3s countdown restarts from the
		# moment the player releases shift, not from when they began
		stamina_recharge.start()
	elif can_recharge and stamina < max_stamina:
		stamina = min(stamina + STAMINA_REFILL * delta, max_stamina)
	stamina_ui.value = stamina
	
	if direction:
		velocity.x = direction * current_speed
		sprite.play(ANIM_WALK)
		# Scale the pivot rather than flipping the sprite, so the bat —
		# a child of the pivot — swings on the correct side of the body.
		if not center_pivot.scale.x == direction:
			center_pivot.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sprite.play(ANIM_IDLE)
		
	# 4. Attack. just_pressed stops a held key retriggering every frame.
	if Input.is_action_just_pressed(SWING_BAT):
		animation.play(ANIM_SWING)
		
	# 5. Last, once every change to velocity above has been applied.
	move_and_slide()
	
# Reduces player health and restarts the level on death.
# amount — damage supplied by the attacking enemy
func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_ui.value = health
	if health <= 0:
		get_tree().call_deferred(RELOAD_SCENE)

# Signal handler — fired by the bat's Area2D when it overlaps a body.
# The group check means only enemies take damage, not walls or floor.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group(GROUP_ENEMY):
		body.take_damage(basic_damage)
		 
# Signal handler — 3s after the last sprint, unlocks stamina refill.
func _on_stamina_recharge_timeout() -> void:
	can_recharge = true
