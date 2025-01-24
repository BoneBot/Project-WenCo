extends RigidBody2D


# The initial launch velocity of the sword
const LAUNCH_VELOCITY := Vector2(300, 300)
const TERMINAL_VELOCITY := 700.0

var allow_rotation := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if get_contact_count() == 0 and allow_rotation:
		# Follow the current trajectory if in the air and allowed to rotate
		look_at(linear_velocity)
	elif allow_rotation:
		# Stop allowing to rotate once an object is hit
		allow_rotation = false

	if Input.is_action_just_pressed("blink"):
		var impulse = Vector2(100, -800)
		print("Wheeee!")
		apply_central_impulse(impulse)
		allow_rotation = true
