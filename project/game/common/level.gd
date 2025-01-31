# level.gd
class_name Level
extends Node2D


signal transition_next_level
signal show_dialogue(text)

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

@onready var sparkles := $Sparkles

var player: CharacterBody2D


func _ready() -> void:
	# Connect exit door signal
	if exit_door.has_signal("player_entered"):
		exit_door.player_entered.connect(finish_level)
	else:
		print("WARNING: Level loaded without a valid exit door!")

	# Connect dialogue signals
	for sparkle in sparkles.get_children():
		if sparkle.has_signal("player_interacted"):
			sparkle.player_interacted.connect(_on_sparkle_player_interacted)


func initialize(player:CharacterBody2D) -> void:
	player.movement_enabled = movement_allowed
	player.dash_enabled = dash_allowed
	player.blink_enabled = blink_allowed
	player.player_death.connect(revive_player)
	self.player = player
	reset()


# Resets the scene to its original state
func reset() -> void:
	if player != null:
		player.position = spawnpoint.position


func finish_level() -> void:
	transition_next_level.emit()


func revive_player() -> void:
	reset()
	player.respawn_timer.start()


func _on_sparkle_player_interacted(text: String) -> void:
	show_dialogue.emit(text)
