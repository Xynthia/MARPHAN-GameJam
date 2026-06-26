class_name Box
extends Area3D

@onready var sfx: AudioStreamPlayer3D = $SFX

@onready var obstacles_crate: Node3D = $obstacles_crate
@onready var obstacles_wrecked_ship: Node3D = $obstacles_wreckedShip
@onready var obstacles_barrel: Node3D = $obstacles_barrel
@onready var random_model : Array[Node3D] = [obstacles_crate, obstacles_wrecked_ship, obstacles_barrel]

var parent : PathFollow3D
var amount_slow_down : int = -5



func _ready() -> void:
	parent = get_parent()
	var random_id : int = randf_range(0, random_model.size()-1)
	for model in random_model:
		if model == random_model[random_id]:
			model.visible = true
		else:
			model.visible = false



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Main.player.play_pickup_audio()
		Main.slow_down(amount_slow_down)
		Main.wave_manager.view_wave(parent)
		Main.boxes_manager.boxes.erase(self)
		queue_free()
