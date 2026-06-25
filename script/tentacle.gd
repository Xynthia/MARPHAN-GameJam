class_name Tentacle
extends Area3D

var parent : PathFollow3D
var amount_slow_down : int = -10

const TENTACLE_EMERGE = preload("uid://drd08pgxjak22")
const TENTACLE_HIT_BOAT = preload("uid://bwf2nk4n2go71")
const TENTACLE_HIT_WATER_MISS = preload("uid://kecvv4rewfjp")

func _ready() -> void:
	parent = get_parent()

func _on_body_entered(body: Node3D) -> void:
	Main.slow_down(amount_slow_down)
	Main.wave_manager.view_wave(parent)
	Main.tentacle_manager.tentacles.erase(self)
	queue_free()
