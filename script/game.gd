class_name Game
extends Node3D

@onready var player: Player = $Player

func _ready() -> void:
	Main.game = self

func _on_passive_speed_increase_timeout() -> void:
	var _rAmount : float = randf_range(0.01, 0.1)
	Main.wave_manager.waves[0].speed += _rAmount
