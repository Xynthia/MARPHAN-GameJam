extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer3D = $tentacle/Skeleton3D/BoneAttachment3D/SFX

var parent : Tentacle

func _ready() -> void:
	parent = get_parent()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") && parent.slam_down:
		parent.hit_player()


func play_slam() -> void:
	parent.slam_down = true
	animation_player.play("tentacle_Slamo")
	await animation_player.animation_finished
	parent.slam_down = false
	parent.play_hit_water()

func play_raise()-> void:
	animation_player.play("tentacle_raise")
	await animation_player.animation_finished
