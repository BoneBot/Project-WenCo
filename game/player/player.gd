extends CharacterBody2D


# CHILDREN
@onready var sprite := $Sprite
@onready var collision := $Collision
@onready var animation_player := $AnimationPlayer
@onready var dash_cooldown := $CooldownTimers/DashCooldown
@onready var blink_cooldown := $CooldownTimers/BlinkCooldown
@onready var projectile_spawn := $ProjectileSpawn
@onready var camera := $Camera

# CONSTANTS
const SPEED := 300.0					# Max walking speed
const ACCELERATION := SPEED * 12.0		# Walking acceleration
const JUMP_VELOCITY := -400.0			# Initial jump speed
const TERMINAL_VELOCITY := 700.0		# Max speed while falling
const DASH_VELOCITY := 1000.0			# Initial dash speed
const BLINK_IMPULSE_MAGNITUE := 600		# Impulse applied when throwing weapon for blink

# EXPORT VARIABLES
## The scene to use when spawning a sword for blink.
@export var sword_scene: PackedScene
## The maximum health the player can have.
@export var max_health := 50
## Current player health.
@export var health := 50

# MEMBER VARIABLES
var sword_instance: RigidBody2D
var dash_ready := true
var blink_ready := true
var is_vanished := false

# ENUMS
enum LookDirectionType {
	LEFT = -1,
	NEUTRAL = 0,
	RIGHT = 1
}


## Process anything upon creation
func _ready() -> void:
	pass


## Process player graphics
func _process(delta: float) -> void:
	# Update look direction
	if Input.is_action_pressed("right") and Input.is_action_pressed("left"):
		# Don't do anything when both directions are pressed at once
		pass
	elif Input.is_action_pressed("right") and get_look_direction() != LookDirectionType.RIGHT:
		# Look right
		look_at_direction(LookDirectionType.RIGHT)
	elif Input.is_action_pressed("left") and get_look_direction() != LookDirectionType.LEFT:
		# Look left
		look_at_direction(LookDirectionType.LEFT)
	
	# Update animation
	var animation := get_new_animation(Input.is_action_just_pressed("attack"))
	if animation != animation_player.current_animation:
		animation_player.play(animation)


## Process player physics
func _physics_process(delta: float) -> void:
	# Do not process any player physics if they are vanished
	if is_vanished:
		return

	if Input.is_action_just_released("blink") and blink_ready:
		blink_ready = false
		if Input.get_axis("left", "right") or Input.get_axis("up", "down"):
			trigger_blink()
		else:
			blink_cooldown.start()
	elif Input.is_action_pressed("blink") and blink_ready:
		# Handle blink-hold inputs
		handle_blink_hold_inputs()
	else:
		# Handle normal inputs
		handle_normal_inputs(delta)

		# Apply gravity
		if not is_on_floor():
			velocity.y = minf(TERMINAL_VELOCITY, velocity.y + get_gravity().y * delta)

	# Move player
	move_and_slide()


## Handles typical player inputs
func handle_normal_inputs(delta: float) -> void:
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.2

	# Handle walking
	var direction := Input.get_axis("left", "right") * SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION * delta)

	# Handle dash
	if Input.is_action_just_pressed("dash") and dash_ready:
		dash_ready = false
		dash_cooldown.start()
		var velocity_threshold = 0.1
		if direction > velocity_threshold:
			# Dash right
			velocity.x = DASH_VELOCITY
		elif direction < -velocity_threshold:
			# Dash left
			velocity.x = -DASH_VELOCITY
		else:
			# No current velocity; base dash direction on the direction the character is looking
			velocity.x = DASH_VELOCITY * get_look_direction()


## Handles inputs when the blink button is held down
func handle_blink_hold_inputs() -> void:
	# Kill all velocity
	if velocity.length() > 0:
		velocity = Vector2.ZERO


## Initiates a blink
func trigger_blink() -> void:
	create_sword_instance()
	vanish_player()
	add_child(sword_instance)
	var direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	sword_instance.apply_central_impulse(direction * BLINK_IMPULSE_MAGNITUE)


## Gets the current direction the player is looking
func get_look_direction() -> LookDirectionType:
	if not sprite.flip_h:
		return LookDirectionType.RIGHT
	else:
		return LookDirectionType.LEFT


## Makes the player look in the specified direction
func look_at_direction(direction: LookDirectionType) -> void:
	if direction == LookDirectionType.RIGHT:
		# Look right
		sprite.flip_h = false
		sprite.offset.x = -absf(sprite.offset.x)
		projectile_spawn.position.x = absf(projectile_spawn.position.x)
	elif direction == LookDirectionType.LEFT:
		# Look left
		sprite.flip_h = true
		sprite.offset.x = absf(sprite.offset.x)
		projectile_spawn.position.x = -absf(projectile_spawn.position.x)


## Gets the current animation to play based on the player state
func get_new_animation(isAttacking: bool) -> String:
	var animation_new: String
	if is_on_floor():
		if "attack" in animation_player.current_animation and animation_player.is_playing():
			animation_new = animation_player.current_animation
		elif isAttacking:
			animation_new = "attack_"
			if get_look_direction() == LookDirectionType.RIGHT:
				animation_new += "right"
			else:
				animation_new += "left"
		elif absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		animation_new = "jump"
	return animation_new


## Creates a new instance of a sword used to blink
func create_sword_instance() -> void:
	sword_instance = sword_scene.instantiate()
	sword_instance.initialize(projectile_spawn.position, _on_blink_triggered)


## Vanishes the player to begin a blink
func vanish_player() -> void:
	camera.enabled = false
	sprite.visible = false
	collision.set_deferred("disabled", true)
	is_vanished = true


## Unvanishes the player to terminate a blink
func unvanish_player() -> void:
	camera.enabled = true
	sprite.visible = true
	collision.set_deferred("disabled", false)
	is_vanished = false


## Kills the player
func die() -> void:
	sprite.visible = false
	collision.set_deferred("disabled", true)
	is_vanished = true


func _on_dash_cooldown_timeout() -> void:
	dash_ready = true


func _on_blink_triggered(blink_position) -> void:
	position = blink_position
	unvanish_player()
	blink_cooldown.start()


func _on_blink_cooldown_timeout() -> void:
	blink_ready = true
	print("Blink ready!")


func _on_hurt_box_damage_taken(damage: Variant) -> void:
	print("Player took %d damage!" % damage)
	health = health - damage
	if health <= 0:
		print("Player died!")
		die()
