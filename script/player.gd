class_name Player
extends CharacterBody3D

const BOAT_RAM_START = preload("uid://b3f5w5lclinej")
const BOAT_RAM_AFTERMATH = preload("uid://cyu4ae57i0t7x")
const BOAT_RAM_HIT = preload("uid://dvpv3rqk66jw3")

const RUNE_BUFFACTIVE = preload("uid://dyb3iep4i8rty")
const RUNE_PICKUP = preload("uid://hltsntomnxd5")

const OBSTACLE_HIT_1 = preload("uid://cvns7k2aebfas")
const OBSTACLE_HIT_2 = preload("uid://cr2lrma1iqtyh")
var hit_audio : Array[AudioStream] = [OBSTACLE_HIT_1, OBSTACLE_HIT_2]

@onready var viking_ship: Node3D = $vikingShip
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var sfx_2: AudioStreamPlayer3D = $SFX2
@onready var sfx_3: AudioStreamPlayer3D = $SFX3
@onready var sfx_rune: AudioStreamPlayer3D = $"SFX Rune"
@onready var sfx_box: AudioStreamPlayer3D = $"SFX Box"
@onready var cam_shake: ColorRect = $CamShake/ColorRect

@onready var wind: GPUParticles3D = $wind
@onready var rain: GPUParticles3D = $rain
@onready var rain_billboard: GPUParticles3D = $rain_Billboard
@onready var fire: GPUParticles3D = $VFX_FireComp/Fire
@onready var spark: GPUParticles3D = $VFX_FireComp/Spark

@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D


enum lanes {LEFT, MIDDLE, RIGHT}
var current_lane : lanes = lanes.RIGHT

var camShake_Tween : Tween

var move_amount : float = 5
var min_turn_amount : int = 7
var max_turn_amount : int = 13
var min_bank_amount : int = 11
var max_bank_amount : int = 18
var min_pitch_amount : int = 3
var max_pitch_amount : int = 1
var turn_normal_amount : Vector3 = Vector3.ZERO

var min_bank_idle_amount : int = 5
var max_bank_idle_amount : int = 10

var octopus_hit_pos : Vector3 = Vector3(15, 0.5, 3)
var start_pos : Vector3 

var attacking : bool = false

var last_dir : Vector3 

var moving : bool = false :
	set(value):
		moving = value
		
		if moving == false:
			animation_idle()

func _ready() -> void:
	Main.player = self
	moving = false
	start_pos = global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ramming") && Main.octopus.is_in_middle_pos && !attacking:
		attack_octupus()
	
	if event.is_action_pressed("move left"):
		move_lane(Vector3.MODEL_LEFT)
	if event.is_action_pressed("move right"):
		move_lane(Vector3.MODEL_RIGHT)

func set_shader(value: float):
	value = (0.75 + value)
	wind.speed_scale = value
	rain.speed_scale = value
	rain_billboard.speed_scale = value
	fire.speed_scale = value
	spark.speed_scale = value

func set_camShakesmoothly(target_value: float):
	if camShake_Tween:
		camShake_Tween.kill()
	
	camShake_Tween = create_tween().set_parallel(true)
	
	camShake_Tween.tween_method(
		func(val): cam_shake.material.set_shader_parameter("ShakeStrength", val),
		cam_shake.material.get_shader_parameter("ShakeStrength"),
		target_value,
		1
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await camShake_Tween.finished

func play_start_ram() ->  void:
	sfx_3.pitch_scale = randf_range(0.9, 1.1)
	sfx_3.play()
	set_camShakesmoothly(1.5) #speed up
	await sfx_3.finished

func play_audio_hit() -> void:
	#sfx.stream = BOAT_RAM_HIT
	sfx.pitch_scale = randf_range(0.9, 1.1)
	sfx.play()
	set_camShakesmoothly(4.0) # heavy
	get_tree().create_timer(1.0).timeout
	sfx_2.pitch_scale = randf_range(0.9, 1.1)
	sfx_2.play()
	set_camShakesmoothly(0.35) # normal
	await sfx_2.finished

func play_pickup() -> void:
	#sfx_rune.stream = RUNE_PICKUP
	sfx_rune.pitch_scale = randf_range(0.9, 1.1)
	sfx_rune.play()
	set_camShakesmoothly(0.65) # slightly faster
	await sfx_rune.finished

func play_pickup_audio() -> void:
	var rand_id = randi_range(0, hit_audio.size() -1)
	sfx_box.stream = hit_audio[rand_id]
	sfx_box.pitch_scale = randf_range(0.9, 1.1)
	sfx_box.play()
	await sfx_box.finished
	await set_camShakesmoothly(1.5) # heavy
	set_camShakesmoothly(0.35) # normal

func animation_idle() -> void:
	var tween_idle_bank : Tween = create_tween()
	var tween_idle_pitch : Tween = create_tween()
	
	tween_idle_bank.set_loops()
	tween_idle_pitch.set_loops()
	var bank_amount : int = randi_range(min_bank_idle_amount, max_bank_idle_amount)
	var pitch_amount : int = randi_range(min_pitch_amount, max_pitch_amount)
	
	tween_idle_bank.tween_property(viking_ship, "rotation_degrees:z", bank_amount, 3)
	tween_idle_pitch.tween_property(viking_ship, "rotation_degrees:x", pitch_amount, 3)
	
	tween_idle_bank.tween_interval(0.1)
	tween_idle_pitch.tween_interval(0.1)
	
	tween_idle_bank.tween_property(viking_ship, "rotation_degrees:z", 0, 3)
	tween_idle_pitch.tween_property(viking_ship, "rotation_degrees:x", 0, 3)
	
	tween_idle_bank.tween_interval(2)
	tween_idle_pitch.tween_interval(2)

func attack_octupus() -> void:
	attacking = true
	play_start_ram()
	Main.wave_manager.set_speed(Main.wave_manager.waves[0].max_speed)
	await move_into_octopus()
	play_audio_hit()
	if !Main.octopus.mouth_open:
		Main.octopus.take_damage()
		Main.wave_manager.set_speed(Main.wave_manager.waves[0].start_speed)
		move_back_to_start_pos()
		current_lane = lanes.RIGHT
		await Main.octopus.move_to_start()
	else:
		Main.die()
	
	attacking = false

func move_into_octopus() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", octopus_hit_pos, 3)
	await tween.finished

func move_back_to_start_pos() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "global_position", start_pos, 3)
	await tween.finished

func move_lane(dir : Vector3) -> void:
	var tween_move : Tween = create_tween()
	var tween_bank : Tween = create_tween()
	var tween_turn : Tween = create_tween()
	var tween_pitch : Tween = create_tween()
	
	var next_lane : lanes
	var move_dir : float = self.global_position.x
	var move_foward_dir : float = self.global_position.z
	var turn_dir : float = self.rotation_degrees.y
	var bank_dir : float = self.rotation_degrees.z
	var pitch_amount = randi_range(min_pitch_amount, max_pitch_amount)
	
	if moving:
		if last_dir == dir:
			return
		else:
			match current_lane:
				lanes.LEFT:
					next_lane = lanes.LEFT
					move_dir = 10
					move_foward_dir = 5
					turn_dir += randi_range(min_turn_amount ,max_turn_amount)
					bank_dir += randi_range(min_bank_amount ,max_bank_amount)
				lanes.MIDDLE:
					next_lane = lanes.MIDDLE
					move_dir = 15
					move_foward_dir = 10
					turn_dir -= randi_range(min_turn_amount ,max_turn_amount)
					bank_dir -= randi_range(min_bank_amount ,max_bank_amount)
				lanes.RIGHT:
					next_lane = lanes.RIGHT
					move_dir = 20
					move_foward_dir = 15
					turn_dir -= randi_range(min_turn_amount ,max_turn_amount)
					bank_dir -= randi_range(min_bank_amount ,max_bank_amount)
	else:
		last_dir = dir
		moving = true
		match current_lane:
			lanes.LEFT:
				match dir:
					Vector3.MODEL_RIGHT:
						next_lane = lanes.MIDDLE
						move_dir = 15
						move_foward_dir = 10
						turn_dir -= randi_range(min_turn_amount ,max_turn_amount)
						bank_dir -= randi_range(min_bank_amount ,max_bank_amount)
			lanes.MIDDLE:
				match dir:
					Vector3.MODEL_LEFT:
						next_lane = lanes.LEFT
						move_dir = 10
						move_foward_dir = 5
						turn_dir += randi_range(min_turn_amount ,max_turn_amount)
						bank_dir += randi_range(min_bank_amount ,max_bank_amount)
					Vector3.MODEL_RIGHT:
						next_lane = lanes.RIGHT
						move_dir = 20
						move_foward_dir = 15
						turn_dir -= randi_range(min_turn_amount ,max_turn_amount)
						bank_dir -= randi_range(min_bank_amount ,max_bank_amount)
			lanes.RIGHT:
				match dir:
					Vector3.MODEL_LEFT:
						next_lane = lanes.MIDDLE
						move_dir = 15
						move_foward_dir = 10
						turn_dir += randi_range(min_turn_amount ,max_turn_amount)
						bank_dir += randi_range(min_bank_amount ,max_bank_amount)
	
	
	if next_lane != null:
		var new_move = Vector3(move_dir, 0, move_foward_dir)
		tween_move.tween_property(self, "global_position", new_move, 2.25)
		
		tween_pitch.set_ease(Tween.EASE_IN)
		tween_pitch.set_trans(Tween.TRANS_BOUNCE)
		tween_pitch.tween_property(viking_ship, "rotation_degrees:x", pitch_amount, 3)
		tween_pitch.set_ease(Tween.EASE_OUT)
		tween_pitch.chain().tween_property(viking_ship, "rotation_degrees:x", 0, 3)

		tween_turn.set_trans(Tween.TRANS_BACK)
		# turn left
		tween_turn.set_ease(Tween.EASE_OUT)
		tween_turn.tween_property(viking_ship, "rotation_degrees:y", turn_dir, 2)
		#turn right
		tween_turn.set_ease(Tween.EASE_IN)
		tween_turn.chain().tween_property(viking_ship, "rotation_degrees:y", -turn_dir /2, 2)
		#return
		tween_turn.set_ease(Tween.EASE_OUT_IN)
		tween_turn.chain().tween_property(viking_ship, "rotation_degrees:y", turn_normal_amount.y, 2)
	
		tween_bank.set_trans(Tween.TRANS_BACK)
		# turn left
		tween_bank.set_ease(Tween.EASE_OUT)
		tween_bank.tween_property(viking_ship, "rotation_degrees:z", bank_dir, 2)
		#turn right
		tween_bank.set_ease(Tween.EASE_IN)
		tween_bank.chain().tween_property(viking_ship, "rotation_degrees:z", -bank_dir /2, 2)
		#return
		tween_bank.set_ease(Tween.EASE_OUT_IN)
		tween_bank.chain().tween_property(viking_ship, "rotation_degrees:z", turn_normal_amount.z, 2)
	
		await tween_move.finished 
		if global_position == new_move:
			current_lane = next_lane
		moving = false
		await tween_turn.finished
