# castle_2.gd
extends Node2D


@onready var spawnpoint := $Spawnpoint

var player: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func initialize(player:CharacterBody2D) -> void:
	self.player = player
	reset()


# Resets the scene to its original state
func reset() -> void:
	if player != null:
		player.position = spawnpoint.position
