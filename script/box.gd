class_name Box
extends Area3D


var parent : PathFollow3D
var amount_slow_down : int = -5

func _ready() -> void:
	parent = get_parent()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Main.slow_down(amount_slow_down)
		Main.wave_manager.view_wave(parent)
		Main.boxes_manager.boxes.erase(self)
		queue_free()
		
