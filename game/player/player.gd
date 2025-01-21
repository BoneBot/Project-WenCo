extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const TERMINAL_VELOCITY = 700


func _ready() -> void:
	pass



func _physics_process(delta: float) -> void:
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 0

	# Apply gravity
	if not is_on_floor():
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + get_gravity().y * delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func flip_sprite() -> void:
	$Sprite.flip_h = !$Sprite.flip_h
	$Sprite.offset.x = -$Sprite.offset.x
