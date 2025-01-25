class_name HurtBox
extends Area2D


signal damage_taken(damage)


func take_damage(damage: int) -> void:
	damage_taken.emit(damage)
