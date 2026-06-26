class_name SpawnManager
extends Node3D

var waves : Array[Wave]

func _ready() -> void:
	Main.spawn_manager = self

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Wave") :
		waves.append(area)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("Wave"):
		waves.erase(area)
