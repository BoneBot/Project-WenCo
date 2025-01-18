extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

# Resets the scene to its original state
func reset() -> void:
	$Player.position = $DemoMap/Spawnpoint.position
