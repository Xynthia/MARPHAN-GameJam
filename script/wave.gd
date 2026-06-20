class_name Wave
extends Node3D

var parent : PathFollow3D
var time : float = 0.2

@onready var csg_box_3d: CSGBox3D = $CSGBox3D

var moving_below : bool = false :
	set(value):
		idle(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moving_below = false
	parent = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	parent.progress_ratio += time * delta


func idle(is_moving) -> void:
	var tween : Tween = create_tween()
	var random_pos : Vector3
	random_pos.x += randf_range(0, 10)
	random_pos.z += randf_range(0, 1)

	if !is_moving:
		tween.tween_property(csg_box_3d, "global_position:y", 0, 1)
		tween.tween_property(csg_box_3d, "global_rotation_degrees:x", random_pos.x, 2)
		tween.tween_interval(0.1)
		tween.tween_property(csg_box_3d, "global_rotation_degrees:x", -random_pos.x, 2)
		await tween.finished
		idle(moving_below)
	else:
		tween.tween_property(csg_box_3d, "global_position:y", -4, 1)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moving_below = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moving_below = false
