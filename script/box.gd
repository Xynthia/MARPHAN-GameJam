class_name Box
extends Area3D

@onready var sfx: AudioStreamPlayer3D = $SFX

var parent : PathFollow3D
var amount_slow_down : int = -5

const OBSTACLE_HIT_1 = preload("uid://cvns7k2aebfas")
const OBSTACLE_HIT_2 = preload("uid://cr2lrma1iqtyh")
var hit_audio : Array[AudioStream] = [OBSTACLE_HIT_1, OBSTACLE_HIT_2]

func _ready() -> void:
	parent = get_parent()
func play_pickup_audio() -> void:
	var rand_id = randi_range(0, hit_audio.size() -1)
	sfx.stream = hit_audio[rand_id]
	sfx.play()
	await sfx.finished

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		play_pickup_audio()
		Main.slow_down(amount_slow_down)
		Main.wave_manager.view_wave(parent)
		Main.boxes_manager.boxes.erase(self)
		queue_free()
