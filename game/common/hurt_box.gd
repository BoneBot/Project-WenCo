class_name HurtBox
extends Area2D


signal damage_taken(damage:int)


func take_damage(damage: int) -> void:
	if monitoring:
		damage_taken.emit(damage)
