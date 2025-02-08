extends RigidBody2D


# Emitted when the sword triggers blink
# blink_position: The global coordinate to teleport the player to
signal blink_triggered(blink_position)

# The distance away from the point of impact to set the blink teleport position
@export var blink_displacement = 20


# Initializes the contents of the sword
# projectile_position: The global position coordinates to spawn the sword at
# flip: Whether or not to flip the x position of the sword when spawning it
# blink_signal_callable: Optional. The callable to connect the blink_triggered signal to
func initialize(projectile_position:Vector2, flip:bool, blink_signal_callable:Callable=Callable()) -> void:
	position = projectile_position
	if flip:
		position.x = -position.x
	if not blink_signal_callable.is_null():
		blink_triggered.connect(blink_signal_callable)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera.enabled = true


func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0.1:
		# Follow the current trajectory while moving
		look_at(linear_velocity + position)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if get_contact_count() > 0:
		var collision_normal = state.get_contact_local_normal(0)
		blink_to_sword(collision_normal)


func blink_to_sword(collision_normal=null) -> void:
	# Calculate the blink position
	var blink_position = null
	if collision_normal != null:
		var teleport_direction = (2 * collision_normal - linear_velocity.normalized()).normalized()
		blink_position = global_position + teleport_direction * blink_displacement

	# Release camera control
	$Camera.enabled = false

	# Emit blink signal
	blink_triggered.emit(blink_position)

	# Kill thyself now (or, you know, whenever is convenient)
	queue_free()
