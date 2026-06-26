class_name Rune
extends Area3D

@onready var sfx: AudioStreamPlayer3D = $SFX

var parent : PathFollow3D
var amount_speed_up : int = 10



func _ready() -> void:
	parent = get_parent()



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Main.player.play_pickup()
		Main.speed_up(amount_speed_up)
		Main.wave_manager.view_wave(parent)
		Main.rune_manager.runes.erase(self)
		queue_free()
