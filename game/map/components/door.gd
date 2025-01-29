extends Area2D


## Emitted when the player enters the door
signal player_entered


func _physics_process(delta: float) -> void:
	if has_overlapping_bodies() and Input.is_action_just_pressed("up"):
		player_entered.emit()
