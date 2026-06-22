class_name Rune
extends Area3D

var parent : PathFollow3D

func _ready() -> void:
	parent = get_parent()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Main.speed_up()
		Main.wave_manager.view_wave(parent)
		Main.rune_manager.runes.erase(self)
		queue_free()
