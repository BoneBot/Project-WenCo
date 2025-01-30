extends Node


## The level scenes, arranged in the order that they are played. 
## i.e. level_scenes[0] --> level_scenes[1] --> level_scenes[2] --> etc. 
## After the last level is completed, the main menu is displayed again. 
@export var level_scenes: Array[PackedScene]
## The player scene
@export var player_scene: PackedScene

@onready var main_menu = $UI/MainMenu

var current_level
var current_level_index := 0
var player


func _ready() -> void:
	pass


func load_level(index: int) -> void:
	# Create new level
	current_level = level_scenes[index].instantiate()

	# Connect level transition signal
	current_level.transition_next_level.connect(advance_level)

	# Add level to game tree
	add_child(current_level)
	move_child(current_level, 0)


func unload_current_level() -> void:
	current_level.transition_next_level.disconnect(advance_level)
	current_level.queue_free()


func start_game() -> void:
	current_level_index = 0
	load_level(current_level_index)

	player = player_scene.instantiate()
	current_level.add_child(player)
	if current_level.has_method("initialize"):
		current_level.initialize(player)


# Advance from the current level to the next level in the level scene array
func advance_level() -> void:
	# Unload previous level
	unload_current_level()
	current_level_index += 1

	# Check if we have reached the last level
	if current_level_index < len(level_scenes):
		# Load next level
		load_level(current_level_index)

		# Place player
		player = player_scene.instantiate()
		current_level.add_child(player)
		if current_level.has_method("initialize"):
			current_level.initialize(player)

	else:
		# Finished the final level; return to main menu
		player.queue_free()
		main_menu.show()
