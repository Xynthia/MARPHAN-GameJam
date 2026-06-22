class_name Octupus
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var random_time_between_attacks : float = randf_range(3.0, 10.0)
var timer_attack : float = 0.0
var attacking : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if !attacking:
		timer_attack += delta
		if timer_attack >= random_time_between_attacks:
			timer_attack = 0
			random_time_between_attacks = randf_range(5.0, 10.0)
			attack()

func attack() -> void:
	attacking = true
	await play_arm_up()
	var random_time : float = randf_range(5.0, 10.0)
	await get_tree().create_timer(random_time).timeout
	await play_slam_down()
	attacking = false

func play_arm_up() -> void:
	animation_player.play("arm up")
	await animation_player.animation_finished

func play_slam_down() -> void:
	animation_player.play("slam_down")
	await animation_player.animation_finished
