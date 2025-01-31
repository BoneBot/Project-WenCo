# level.gd
class_name Level
extends Node2D


signal transition_next_level

## The spawn location of the player
@export var spawnpoint: Marker2D
## The exit door of the level. Must be a Door.tscn.
@export var exit_door: Node2D
## Whether or not the player can move in the level.
@export var movement_allowed := true
## Whether or not the player can use dash in the level. 
@export var dash_allowed := true
## Whether or not the player can use blink in the level.
@export var blink_allowed := true

var player: CharacterBody2D


func _ready() -> void:
	if exit_door.has_signal("player_entered"):
		exit_door.player_entered.connect(finish_level)
	else:
		print("WARNING: Level loaded without a valid exit door!")


func initialize(player:CharacterBody2D) -> void:
	player.movement_enabled = movement_allowed
	player.dash_enabled = dash_allowed
	player.blink_enabled = blink_allowed
	self.player = player
	reset()


# Resets the scene to its original state
func reset() -> void:
	if player != null:
		player.position = spawnpoint.position


func finish_level() -> void:
	transition_next_level.emit()
