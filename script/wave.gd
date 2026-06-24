class_name Wave
extends Node3D


var parent : PathFollow3D
var start_speed : float = 15
var max_speed: float = 50
var ramming_speed : float = (max_speed/ 100) * 75
var speed : float :
	set(value):
		speed = clamp(value, 0, max_speed)
		if Main.ui:
			Main.ui.player_speed_bar.value = speed
		
		if speed == 0:
			Main.die()
		if speed >= ramming_speed:
			Main.ramming_speed = true
		else:
			Main.ramming_speed = false
		

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

var moving_below : bool = false :
	set(value):
		idle(value)

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
		tween.tween_property(csg_box_3d, "global_position:y", 0, 1.5)
		tween.tween_property(csg_box_3d, "global_rotation_degrees:x", random_pos.x, 2)
		tween.tween_interval(0.1)
		tween.tween_property(csg_box_3d, "global_rotation_degrees:x", -random_pos.x, 2)
		await tween.finished
		idle(moving_below)
	else:
		tween.tween_property(csg_box_3d, "global_position:y", -8, 1)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moving_below = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moving_below = false
