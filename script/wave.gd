class_name Wave
extends Node3D


var parent : PathFollow3D
var start_speed : float = 15
var max_speed: float = 50
var ramming_speed : float = (max_speed/ 100) * 75

var ui_tween: Tween

var speed : float :
	set(value):
		speed = clamp(value, 0, max_speed)
		if Main.ui:
			animate_ui_smoothly(value)
		
		if speed == 0:
			Main.die()
		if Main.ramming_speed == false && speed >= ramming_speed:
			Main.ramming_speed = true
		elif Main.ramming_speed == true && speed <= ramming_speed:
			Main.ramming_speed = false
		

@onready var water_model: Node3D = $water_model

var moving_below : bool = false :
	set(value):
		idle(value)

func animate_ui_smoothly(target_value: float):
	if ui_tween:
		ui_tween.kill()
	
	ui_tween = create_tween().set_parallel(true)
	
	ui_tween.tween_property(Main.ui.player_speed_bar_tex, "value", target_value, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	var target_progress = target_value / max_speed
	ui_tween.tween_method(
		func(val): Main.ui.player_speed_bar.material.set_shader_parameter("progress", val),
		Main.ui.player_speed_bar.material.get_shader_parameter("progress"),
		target_progress,
		0.45
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _ready() -> void:
	moving_below = false
	parent = get_parent()
	speed = start_speed

func _process(delta: float) -> void:
	parent.progress_ratio += delta * speed /100

func idle(is_moving) -> void:
	var tween : Tween = create_tween()
	var random_pos : Vector3
	random_pos.x += randf_range(0, 10)
	random_pos.z += randf_range(0, 1)

	if !is_moving:
		tween.tween_property(water_model, "global_position:y", 0, 1.5)
		tween.tween_property(water_model, "global_rotation_degrees:x", random_pos.x, 2)
		tween.tween_interval(0.1)
		tween.tween_property(water_model, "global_rotation_degrees:x", -random_pos.x, 2)
		await tween.finished
		idle(moving_below)
	else:
		tween.tween_property(water_model, "global_position:y", -8, 1)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moving_below = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moving_below = false
