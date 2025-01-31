extends RigidBody2D


@onready var pivot := $Pivot
@onready var sprite := $Pivot/Sprite
@onready var vision := $Pivot/Vision
@onready var vision_collision := $Pivot/Vision/VisionCollision
@onready var attack_timer := $AttackTimer
@onready var animation_player := $AnimationPlayer

## Whether or not to spawn the knight facing right.
@export var facing_right := true
## Knight health.
@export var health := 20


func _ready() -> void:
	if not facing_right:
		facing_right = true	# Temporarily setting to true so the sprite will turn left when it flips
		turn_around()


func turn_around() -> void:
	if facing_right:
		# Turn to face left
		pivot.scale.x = -1
	else:
		# Turn to face right
		pivot.scale.x = 1


func attack() -> void:
	if animation_player.current_animation != "attack":
		animation_player.call_deferred("play", "attack")


func _on_vision_body_entered(body: Node2D) -> void:
	# Attack once and continue attacking until the player leaves the vision area
	attack()
	attack_timer.start()


func _on_attack_timer_timeout() -> void:
	# Attack
	attack()

	# Stop attacking if player is no longer in vision range
	if not vision.has_overlapping_bodies():
		attack_timer.stop()


func _on_hurt_box_damage_taken(damage: Variant) -> void:
	health -= damage
	if health <= 0:
		animation_player.call_deferred("play", "die")
	else:
		animation_player.call_deferred("play", "hurt")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" or anim_name == "hurt":
		animation_player.call_deferred("play", "idle")
	elif anim_name == "die":
		queue_free()
