class_name Octupus
extends Node3D

var health : int = 100:
	set(value):
		pass

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var random_time_between_attacks : float = randf_range(3.0, 10.0)
var timer_attack : float = 0.0
var attacking : bool = false

var mouth_open : bool = false
var mouth_attack_timer : float = 0.0

var amount_damage_per_hit : int = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.octopus = self


func _process(delta: float) -> void:
	if !mouth_open:
		mouth_attack_timer += delta
		if mouth_attack_timer >= random_time_between_attacks:
			mouth_attack_timer = 0
			random_time_between_attacks = randf_range(3.0, 10.0)
			mouth_attack()
	
	#if !attacking:
		#timer_attack += delta
		#if timer_attack >= random_time_between_attacks:
			#timer_attack = 0
			#random_time_between_attacks = randf_range(5.0, 10.0)
			#attack()

func take_damage() -> void:
	health -= amount_damage_per_hit

func open_mouth() ->void:
	animation_player.play("open_mouth")
	await animation_player.animation_finished

func close_mouth() -> void:
	animation_player.play("close_mouth")
	await animation_player.animation_finished

func mouth_attack() -> void:
	mouth_open = true
	await open_mouth()
	var random_time : float = randf_range(5.0, 10.0)
	await get_tree().create_timer(random_time).timeout
	await close_mouth()
	mouth_open = false

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
