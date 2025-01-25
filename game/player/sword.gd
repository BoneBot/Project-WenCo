extends RigidBody2D


signal blink_triggered(collision_normal)


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
	blink_triggered.emit(collision_normal)
	$Camera.enabled = false
	queue_free()
