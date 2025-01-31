extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_hurt_box_damage_taken(damage: Variant) -> void:
	print("Dummy took %d damage!" % damage)
	$HitRecover.start()
	$Sprite.visible = false
	$HurtBox.set_deferred("monitoring", false)


func _on_hit_recover_timeout() -> void:
	$Sprite.visible = true
	$HurtBox.set_deferred("monitoring", true)
