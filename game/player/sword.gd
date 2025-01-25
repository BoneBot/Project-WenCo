extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if linear_velocity.length() > 0.1:
		# Follow the current trajectory while moving
		look_at(linear_velocity + position)


func _on_body_entered(body: Node) -> void:
	# Destroy sword when it comes into contact with a body
	queue_free()
