class_name Box
extends StaticBody3D

func _process(delta: float) -> void:
	global_position.z += delta
