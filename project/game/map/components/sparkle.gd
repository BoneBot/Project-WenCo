# sparkles.gd
extends Area2D


signal player_interacted(text)

## The text for this set of sparkles to display when interacting. 
## Separate successive text popups with newlines.
@export_multiline var prompt_text: String

@onready var sprite := $Sprite


func _ready() -> void:
	sprite.play("default")


func _physics_process(delta: float) -> void:
	if has_overlapping_bodies() and Input.is_action_just_pressed("up"):
		player_interacted.emit(prompt_text)
