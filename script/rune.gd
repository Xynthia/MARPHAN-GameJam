class_name Rune
extends Area3D

var parent : PathFollow3D
var amount_speed_up : int = 10

const RUNE_BUFFACTIVE = preload("uid://dyb3iep4i8rty")
const RUNE_PICKUP = preload("uid://hltsntomnxd5")


func _ready() -> void:
	parent = get_parent()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		Main.speed_up(amount_speed_up)
		Main.wave_manager.view_wave(parent)
		Main.rune_manager.runes.erase(self)
		queue_free()
