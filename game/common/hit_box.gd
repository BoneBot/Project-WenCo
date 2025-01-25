class_name HitBox
extends Area2D


@export var damage := 10.0


func _ready() -> void:
	connect("area_entered", _on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage)
