class_name Octupus
extends Node3D

@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var monstie_combo_wanims: OctopusAnimations = $monstie_combo_wanims

const MONSTER_IDLE_CLOSED_1 = preload("uid://cnwml61ldcx58")
const MONSTER_IDLE_CLOSED_2 = preload("uid://bu5jymhle4k65")
const MONSTER_IDLE_CLOSED_3 = preload("uid://dy5dhf60p6rjb")
var monster_closed : Array[AudioStream] = [MONSTER_IDLE_CLOSED_1, MONSTER_IDLE_CLOSED_2, MONSTER_IDLE_CLOSED_3]

const MONSTER_IDLE_OPEN_1 = preload("uid://bigigb8sq54f0")
const MONSTER_IDLE_OPEN_2 = preload("uid://1ssyi7p5cm65")
const MONSTER_IDLE_OPEN_3 = preload("uid://cy3fwkbuyno44")
var monster_open : Array[AudioStream] = [MONSTER_IDLE_OPEN_1, MONSTER_IDLE_OPEN_2, MONSTER_IDLE_OPEN_3]

const BOAT_RAM_MONSTER_AFTERMATH = preload("uid://ddjfmvi7irkw8")
const BOAT_RAM_MONSTER_HIT = preload("uid://xjgsbov4ivvj")
const BOAT_RAM_MONSTER_REACTION = preload("uid://dbpyuqi6256cl")

const MONSTER_DEATH = preload("uid://dhd0jrfp7xaa7")

var ui_tween: Tween

var max_health : float = 100
var health : float :
	set(value):
		health = clampf(value, 0, max_health)
		if Main.ui:
			animate_ui_smoothly(health)
		if health == 0:
			play_audio_dead()
			Main.won()

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var random_time_between_attacks : float = randf_range(3.0, 10.0)
var timer_attack : float = 0.0
var attacking : bool = false

var mouth_open : bool = false :
	set(value):
		mouth_open = value
		if mouth_open == false:
			monstie_combo_wanims.play_idle()
var mouth_attack_timer : float = 0.0
var amount_damage_per_hit : int = 50

var starting_pos : Vector3
var middle_pos : Vector3 = Vector3(15, 0, 0)
var is_in_middle_pos : bool = false:
	set(value):
		is_in_middle_pos = value
		if is_in_middle_pos == true:
			Main.ui.ramming_label.visible = true
			mouth_attack()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main.octopus = self
	mouth_open = false
	health = max_health
	starting_pos = global_position

func _process(delta: float) -> void:
	if !mouth_open && !Main.player.attacking && is_in_middle_pos:
		mouth_attack_timer += delta
		if mouth_attack_timer >= random_time_between_attacks:
			mouth_attack_timer = 0
			random_time_between_attacks = randf_range(1.0, 3.0)
			mouth_attack()
	
	
	look_at(Main.player.global_position, Vector3.UP, true)
	#if !attacking:
		#timer_attack += delta
		#if timer_attack >= random_time_between_attacks:
			#timer_attack = 0
			#random_time_between_attacks = randf_range(5.0, 10.0)
			#attack()


func animate_ui_smoothly(target_value: float):
	if ui_tween:
		ui_tween.kill()
	
	ui_tween = create_tween().set_parallel(true)
	
	var target_progress = target_value / max_health
	ui_tween.tween_method(
		func(val): Main.ui.octopus_health_bar.material.set_shader_parameter("progress", val),
		Main.ui.octopus_health_bar.material.get_shader_parameter("progress"),
		target_progress,
		2
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func play_audio_hit() -> void:
	sfx.stream = BOAT_RAM_MONSTER_HIT
	sfx.play()
	await sfx.finished
	sfx.stream = BOAT_RAM_MONSTER_REACTION
	sfx.play()
	await sfx.finished
	sfx.stream = BOAT_RAM_MONSTER_AFTERMATH
	sfx.play()
	await sfx.finished

func play_audio_dead() -> void:
	sfx.stream = MONSTER_DEATH
	sfx.play()
	await sfx.finished

func play_audio_open() -> void:
	var rand_id = randi_range(0, monster_open.size() -1)
	sfx.stream = monster_open[rand_id]
	sfx.play()
	await sfx.finished

func play_audio_closed() -> void:
	var rand_id = randi_range(0, monster_closed.size() -1)
	sfx.stream = monster_closed[rand_id]
	sfx.play()
	await sfx.finished

func take_damage() -> void:
	play_audio_hit()
	health -= (Main.wave_manager.waves[0].speed /100) * amount_damage_per_hit 


func move_to_middle() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", middle_pos, 3)
	await tween.finished
	if global_position == middle_pos:
		is_in_middle_pos = true

func move_to_start() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", starting_pos, 3)
	await tween.finished
	is_in_middle_pos = false

func mouth_attack() -> void:
	mouth_open = true
	play_audio_open()
	await monstie_combo_wanims.play_mouth_open_trans()
	monstie_combo_wanims.play_mouth_open()
	var random_time : float = randf_range(5.0, 10.0)
	await get_tree().create_timer(random_time).timeout
	play_audio_closed()
	await monstie_combo_wanims.play_mouth_closed_trans()
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
