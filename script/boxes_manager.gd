class_name BoxesManager
extends Node3D

const BOX_SCENE = preload("uid://2h5go3uqh1pv")

func _ready() -> void:
	#spawn_box()
	pass

func spawn_box() -> void:
	var new_box = BOX_SCENE.instantiate()
	add_child(new_box)
	new_box.global_position = Vector3(0,0,-10)

func destroy_box(box : Box) -> void:
	box.queue_free()
