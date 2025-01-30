# level.gd
class_name Level
extends Node2D


signal transition_next_level

@export var spawnpoint: Marker2D
@export var exit_door: Node2D

var player: CharacterBody2D


func _ready() -> void:
	if exit_door.has_signal("player_entered"):
		exit_door.player_entered.connect(finish_level)
	else:
		print_debug("WARNING: Level loaded without a valid exit door!")


func initialize(player:CharacterBody2D) -> void:
	self.player = player
	reset()


# Resets the scene to its original state
func reset() -> void:
	if player != null:
		player.position = spawnpoint.position


func finish_level() -> void:
	transition_next_level.emit()
