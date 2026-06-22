class_name WaveManager
extends Node3D

enum speeds {SLOW, NORMAL, FAST}

@onready var path_1: Path3D = $Path1
@onready var path_2: Path3D = $Path2
@onready var path_3: Path3D = $Path3

const WAVE = preload("uid://bwkrwr46mhs6x")

var waves : Array[Wave]
var current_speed : speeds = speeds.NORMAL

func _ready() -> void:
	fill_path()
	Main.wave_manager = self

func change_speed(new_speed: speeds) -> void:
	for wave in waves:
		match new_speed:
			speeds.SLOW:
				wave.speed = wave.slow_speed
				current_speed = speeds.SLOW
			speeds.NORMAL:
				wave.speed = wave.normal_speed
				current_speed = speeds.NORMAL
			speeds.FAST:
				wave.speed = wave.fast_speed
				current_speed = speeds.FAST

func spawn_wave(parent : PathFollow3D, distance : int) -> void:
	var new_wave = WAVE.instantiate()
	waves.append(new_wave)
	parent.add_child(new_wave)
	parent.progress = distance

func hide_wave(parent : PathFollow3D) -> void:
	var wave = parent.get_child(0)
	wave.visible = false

func view_wave(parent : PathFollow3D) -> void:
	var wave = parent.get_child(0)
	wave.visible = true

func fill_path() -> void:
	var amount : int = 0
	for follow in path_1.get_children():
		spawn_wave(follow, amount * 4)
		amount += 1
	
	amount = 0
	for follow2 in path_2.get_children():
		spawn_wave(follow2,  amount * 4)
		amount += 1
	
	amount = 0
	for follow3 in path_3.get_children():
		spawn_wave(follow3, amount * 4)
		amount += 1
	
	amount = 0
