class_name Tentacle
extends Node3D

@onready var tentacle_model: Node3D = $tentacle_model

var parent : PathFollow3D
var amount_slow_down : int = -10

const TENTACLE_EMERGE = preload("uid://drd08pgxjak22")
const TENTACLE_HIT_BOAT = preload("uid://bwf2nk4n2go71")
const TENTACLE_HIT_WATER_MISS = preload("uid://kecvv4rewfjp")

var slam_down : bool = false

func _ready() -> void:
	attack()

func attack() -> void:
	play_emerge()
	await tentacle_model.play_raise()
	var random_time : float = randf_range(1.0, 3.0)
	await get_tree().create_timer(random_time).timeout
	await tentacle_model.play_slam()
	Main.tentacle_manager.tentacles.erase(self)
	queue_free()

func play_emerge() -> void:
	tentacle_model.sfx.stream = TENTACLE_EMERGE
	tentacle_model.sfx.play()
	await tentacle_model.sfx.finished

func play_hit_player() -> void:
	tentacle_model.sfx.stream = TENTACLE_HIT_BOAT
	tentacle_model.sfx.play()
	await tentacle_model.sfx.finished

func play_hit_water() -> void:
	tentacle_model.sfx.stream = TENTACLE_HIT_WATER_MISS
	tentacle_model.sfx.play()
	await tentacle_model.sfx.finished

func hit_player() -> void:
	play_hit_player()
	Main.slow_down(amount_slow_down)
