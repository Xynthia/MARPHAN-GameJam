class_name TentacleManager
extends Node3D

const TENTACLE = preload("uid://cbvjvo4xnm27j")

var tentacles : Array[Tentacle]
var max_tentacles : int = 1

func _ready() -> void:
	Main.tentacle_manager = self

func spawn_tentacle(follow_path : PathFollow3D) -> void:
	var new_tentacle = TENTACLE.instantiate()
	tentacles.append(new_tentacle)
	follow_path.add_child(new_tentacle)
