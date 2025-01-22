extends CharacterBody2D


const SPEED := 300.0				# Max walking speed
const ACCELERATION := SPEED * 12.0	# Walking acceleration
const JUMP_VELOCITY := -400.0		# Initial jump speed
const TERMINAL_VELOCITY := 700.0	# Max speed while falling
const DASH_VELOCITY := 1000.0		# Initial dash speed

var _dash_ready := true


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# Update look direction
	var look_threshold = 1
	if Input.is_action_pressed("right") and Input.is_action_pressed("left"):
		# Don't do anything when both directions are pressed at once
		pass
	elif Input.is_action_pressed("right") and get_look_direction() != 1:
		# Look right
		$Sprite.flip_h = false
		$Sprite.offset.x = absf($Sprite.offset.x)
	elif Input.is_action_pressed("left") and get_look_direction() != -1:
		# Look left
		$Sprite.flip_h = true
		$Sprite.offset.x = -absf($Sprite.offset.x)
	
	# Update animation
	var animation := get_new_animation()
	if animation != $Sprite.animation:
		$Sprite.play(animation)


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
	if Input.is_action_just_pressed("dash") and _dash_ready:
		_dash_ready = false
		$DashCooldown.start()
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

	move_and_slide()


func _on_dash_cooldown_timeout() -> void:
	print("Dash ready!")
	_dash_ready = true


# Gets the current direction the player is looking
# 1 = Looking right 
# 0 = Neutral/no direction
# -1 = Looking left 
func get_look_direction() -> int:
	if not $Sprite.flip_h:
		return 1
	else:
		return -1


# Gets the current animation to play based on the player state
func get_new_animation() -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		animation_new = "jump"
	return animation_new
