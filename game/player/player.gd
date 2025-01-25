extends CharacterBody2D


# CHILDREN
@onready var sprite := $Sprite
@onready var animation_player := $AnimationPlayer
@onready var dash_cooldown := $DashCooldown
@onready var projectile_spawn := $ProjectileSpawn

# CONSTANTS
const SPEED := 300.0				# Max walking speed
const ACCELERATION := SPEED * 12.0	# Walking acceleration
const JUMP_VELOCITY := -400.0		# Initial jump speed
const TERMINAL_VELOCITY := 700.0	# Max speed while falling
const DASH_VELOCITY := 1000.0		# Initial dash speed

# EXPORT VARIABLES
@export var sword_scene: PackedScene

# MEMBER VARIABLES
var dash_ready := true
var sword_instance: RigidBody2D

# ENUMS
enum LookDirectionType {
	LEFT = -1,
	NEUTRAL = 0,
	RIGHT = 1
}


func _ready() -> void:
	pass


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


func _physics_process(delta: float) -> void:
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.2

	# Apply gravity
	if not is_on_floor():
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + get_gravity().y * delta)

	# Handle horizontal movement
	var direction := Input.get_axis("left", "right") * SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION * delta)

	# Handle dash
	if Input.is_action_just_pressed("dash") and dash_ready:
		dash_ready = false
		dash_cooldown.start()
		var movement_threshold = 0.1
		if direction > movement_threshold:
			# Dash right
			velocity.x = DASH_VELOCITY
		elif direction < -movement_threshold:
			# Dash left
			velocity.x = -DASH_VELOCITY
		else:
			# No current movement; base dash direction on the direction the character is looking
			velocity.x = DASH_VELOCITY * get_look_direction()

	# Handle blink
	if Input.is_action_just_pressed("blink"):
		sword_instance = sword_scene.instantiate()
		sword_instance.position = projectile_spawn.position
		add_child(sword_instance)
		sword_instance.apply_central_impulse(Vector2(400, -400))

	move_and_slide()


func _on_dash_cooldown_timeout() -> void:
	dash_ready = true


# Gets the current direction the player is looking
func get_look_direction() -> LookDirectionType:
	if not sprite.flip_h:
		return LookDirectionType.RIGHT
	else:
		return LookDirectionType.LEFT


func look_at_direction(direction: LookDirectionType) -> void:
	if direction == LookDirectionType.RIGHT:
		# Look right
		sprite.flip_h = false
		sprite.offset.x = -absf(sprite.offset.x)
	elif direction == LookDirectionType.LEFT:
		# Look left
		sprite.flip_h = true
		sprite.offset.x = absf(sprite.offset.x)


# Gets the current animation to play based on the player state
func get_new_animation(isAttacking: bool) -> String:
	var animation_new: String
	if is_on_floor():
		if isAttacking or (animation_player.current_animation == "attack"):
			animation_new = "attack"
		elif absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		animation_new = "jump"
	return animation_new
