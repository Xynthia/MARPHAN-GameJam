class_name Game
extends Node3D

@onready var player: Player = $Player
@onready var waves_v_2: MeshInstance3D = $Waves_V2

func _ready() -> void:
	Main.game = self

func _on_passive_speed_increase_timeout() -> void:
	if Main.wave_manager.waves[0].speed < 20:
		var _rAmount : float = randf_range(0.01, 0.1)
		Main.speed_up(_rAmount)
		
func set_shader(value: float):
	value = (1 + value)
	waves_v_2.mesh.material.set_shader_parameter("wave_speed", value)
	waves_v_2.mesh.material.set_shader_parameter("wave_frequency", value)
