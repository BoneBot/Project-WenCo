extends RigidBody2D


signal blink_triggered


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera.enabled = true


func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0.1:
		# Follow the current trajectory while moving
		look_at(linear_velocity + position)


func _on_body_entered(body: Node) -> void:
	blink_to_sword()

func blink_to_sword() -> void:
	blink_triggered.emit()
	$Camera.enabled = false
	queue_free()
