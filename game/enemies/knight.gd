extends RigidBody2D


@onready var sprite := $Sprite
@onready var vision := $Vision
@onready var attack_timer := $AttackTimer
@onready var animation_player := $AnimationPlayer

@export var facing_right := true


func _ready() -> void:
	if not facing_right:
		facing_right = true	# Temporarily setting to true so the sprite will turn left when it flips
		turn_around()


func turn_around() -> void:
	if facing_right:
		# Turn to face left
		sprite.flip_h = true
		sprite.position.x = -abs(sprite.position.x)
		vision.position.x = -abs(vision.position.x)
		facing_right = false
	else:
		# Turn to face right
		sprite.flip_h = false
		sprite.position.x = abs(sprite.position.x)
		vision.position.x = abs(vision.position.x)
		facing_right = true


func _on_vision_body_entered(body: Node2D) -> void:
	attack_timer.start()


func _on_attack_timer_timeout() -> void:
	# Attack
	if facing_right:
		animation_player.play("attack_right")
	else:
		animation_player.play("attack_left")

	# Stop attacking if player is no longer in vision range
	if not vision.has_overlapping_bodies():
		attack_timer.stop()


func _on_hurt_box_damage_taken(damage: Variant) -> void:
	print("Knight took %d damage" % damage)
