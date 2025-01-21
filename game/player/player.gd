extends CharacterBody2D


const SPEED = 300.0
const ACCELERATION = SPEED * 12.0
const JUMP_VELOCITY = -400.0
const TERMINAL_VELOCITY = 700


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# Update look direction
	var look_threshold = 1
	if velocity.x > look_threshold and $Sprite.flip_h:
		# Look right
		$Sprite.flip_h = false
		$Sprite.offset.x = absf($Sprite.offset.x)
	elif velocity.x < -look_threshold and not $Sprite.flip_h:
		# Look left
		$Sprite.flip_h = true
		$Sprite.offset.x = -absf($Sprite.offset.x)


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

	move_and_slide()


func flip_sprite() -> void:
	$Sprite.flip_h = !$Sprite.flip_h
	$Sprite.offset.x = -$Sprite.offset.x
