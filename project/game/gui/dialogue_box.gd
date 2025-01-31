extends Control


signal dialogue_finished

@onready var dialogue_text := $MarginContainer/DialogueText

var current_text: PackedStringArray


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible and Input.is_action_just_pressed("jump"):
		if not next_dialogue():
			hide()
			dialogue_finished.emit()


func start_dialogue(text: String) -> void:
	# Parse text by line
	current_text = text.split("\n")

	# Show dialogue
	next_dialogue()
	show()


## Displays the next line of dialogue. 
## Returns true if there is dialogue to display, false otherwise
func next_dialogue() -> bool:
	if current_text.is_empty():
		return false

	dialogue_text.text = current_text[0]
	current_text.remove_at(0)

	return true
