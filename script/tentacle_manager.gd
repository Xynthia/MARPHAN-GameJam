class_name TentacleManager
extends Node3D

const TENTACLE = preload("uid://cbvjvo4xnm27j")


var tentacles : Array[Tentacle]
var max_tentacles : int = 1

var tentacle_pos : Vector3 = Vector3(12, -0.5, 0)
var tentacle_pos_2 : Vector3 = Vector3(17, -0.5, 7)

func _ready() -> void:
	Main.tentacle_manager = self

func spawn_tentacle() -> void:
	var new_tentacle = TENTACLE.instantiate()
	tentacles.append(new_tentacle)
	add_child(new_tentacle)
	
	var spawn_pos : Vector3
	match Main.player.current_lane:
		Main.player.lanes.LEFT:
			spawn_pos = tentacle_pos
		Main.player.lanes.MIDDLE:
			spawn_pos = tentacle_pos
		Main.player.lanes.RIGHT:
			spawn_pos = tentacle_pos_2
	new_tentacle.global_position = spawn_pos
	print(new_tentacle.global_position)
	new_tentacle.look_at(Main.player.global_position, Vector3.UP, true)
