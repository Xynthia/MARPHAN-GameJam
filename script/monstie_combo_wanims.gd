class_name OctopusAnimations
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_mouth_open_trans() -> void:
	animation_player.play("monstiebones|mouthopen_transition")
	await animation_player.animation_finished

func play_mouth_open() -> void:
	animation_player.play("monstiebones|mouthopen")
	await animation_player.animation_finished
	play_mouth_open()

func play_mouth_closed_trans() -> void:
	animation_player.play("monstiebones|mouthopen_transition_reverse")
	await animation_player.animation_finished

func play_idle()-> void:
	animation_player.play("monstiebones|idle")
	await animation_player.animation_finished
	play_idle()
