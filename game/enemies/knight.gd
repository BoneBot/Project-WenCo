extends RigidBody2D


@onready var sprite := $Sprite
@onready var vision := $Vision
@onready var vision_collision := $Vision/CollisionShape2D
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
		sprite.flip_h = true
		sprite.position.x = -abs(sprite.position.x)
		vision_collision.position.x = -abs(vision_collision.position.x)
		facing_right = false
	else:
		# Turn to face right
		sprite.flip_h = false
		sprite.position.x = abs(sprite.position.x)
		vision_collision.position.x = abs(vision_collision.position.x)
		facing_right = true


func attack() -> void:
	if facing_right:
		animation_player.call_deferred("play", "attack_right")
	else:
		animation_player.call_deferred("play", "attack_left")


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
	print("Knight took %d damage" % damage)
	health -= damage
	if health <= 0:
		print("Knight killed!")
		queue_free()
