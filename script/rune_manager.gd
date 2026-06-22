class_name RuneManager
extends Node3D

const RUNE = preload("uid://c3ry4r5ygg5i0")

var runes : Array[Rune]
var max_runes_amount : int = 3

func _ready() -> void:
	Main.rune_manager = self

func spawn_rune(follow_path : PathFollow3D) -> void:
	var new_rune = RUNE.instantiate()
	runes.append(new_rune)
	follow_path.add_child(new_rune)
