extends Node


## The level scenes, arranged in the order that they are played. 
## i.e. level_scenes[0] --> level_scenes[1] --> level_scenes[2] --> etc. 
## After the last level is completed, the main menu is displayed again. 
@export var level_scenes: Array[PackedScene]
## The player scene
@export var player_scene: PackedScene


var current_level
var player


func _ready() -> void:
	pass


func start_game() -> void:
	current_level = level_scenes[0].instantiate()
	add_child(current_level)
	move_child(current_level, 0)
	
	player = player_scene.instantiate()
	current_level.add_child(player)
	if current_level.has_method("initialize"):
		current_level.initialize(player)
