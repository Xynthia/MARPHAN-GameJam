class_name BoxesManager
extends Node3D

enum speeds {SLOW, NORMAL, FAST}

const BOX_SCENE = preload("uid://2h5go3uqh1pv")

var boxes : Array[Box]
var max_amount_boxes : int = 1

func _ready() -> void:
	Main.boxes_manager = self

func spawn_box(follow_path : PathFollow3D) -> void:
	var new_box = BOX_SCENE.instantiate()
	boxes.append(new_box)
	follow_path.add_child(new_box)
