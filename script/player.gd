class_name Player
extends CharacterBody3D

@onready var csg_box_3d: CSGBox3D = $CSGBox3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

enum lanes {LEFT, MIDDLE, RIGHT}
var current_lane : lanes = lanes.RIGHT

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


var moving : bool = false :
	set(value):
		animation_idle(value)

func _ready() -> void:
	moving = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move left") && !moving:
		move_lane(Vector3.MODEL_LEFT)
	if event.is_action_pressed("move right") && !moving:
		move_lane(Vector3.MODEL_RIGHT)

func animation_idle(is_moving: bool) -> void:
	var tween_idle_bank : Tween = create_tween()
	var tween_idle_pitch : Tween = create_tween()
	if !is_moving:
		tween_idle_bank.set_loops()
		tween_idle_pitch.set_loops()
		var bank_amount : int = randi_range(min_bank_idle_amount, max_bank_idle_amount)
		var pitch_amount : int = randi_range(min_pitch_amount, max_pitch_amount)
		
		tween_idle_bank.tween_property(csg_box_3d, "rotation_degrees:z", bank_amount, 3)
		tween_idle_pitch.tween_property(csg_box_3d, "rotation_degrees:x", pitch_amount, 3)
		
		tween_idle_bank.tween_interval(0.1)
		tween_idle_pitch.tween_interval(0.1)
		
		tween_idle_bank.tween_property(csg_box_3d, "rotation_degrees:z", 0, 3)
		tween_idle_pitch.tween_property(csg_box_3d, "rotation_degrees:x", 0, 3)
		
		tween_idle_bank.tween_interval(2)
		tween_idle_pitch.tween_interval(2)
	else:
		tween_idle_bank.kill()
		tween_idle_pitch.kill()

func attack_octupus() -> void:
	if !Main.octopus.mouth_open:
		Main.octopus.take_damage()
		Main.wave_manager.set_speed(15)
	else:
		#die
		pass

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
	
	match current_lane:
		lanes.LEFT:
			match dir:
				Vector3.MODEL_LEFT:
					next_lane = lanes.LEFT
					#attack_octupus()
					pass
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
				Vector3.MODEL_RIGHT:
					next_lane = lanes.RIGHT
					#maybe hit side of board?
					pass
	
	if next_lane != null && current_lane != next_lane:
		moving = true
		var new_move = Vector3(move_dir, 0, move_foward_dir)
		tween_move.tween_property(self, "global_position", new_move, 3)
		
		tween_pitch.set_ease(Tween.EASE_IN)
		tween_pitch.set_trans(Tween.TRANS_BOUNCE)
		tween_pitch.tween_property(csg_box_3d, "rotation_degrees:x", pitch_amount, 3)
		tween_pitch.set_ease(Tween.EASE_OUT)
		tween_pitch.chain().tween_property(csg_box_3d, "rotation_degrees:x", 0, 3)
	
		tween_turn.set_trans(Tween.TRANS_BACK)
		# turn left
		tween_turn.set_ease(Tween.EASE_OUT)
		tween_turn.tween_property(csg_box_3d, "rotation_degrees:y", turn_dir, 2)
		#turn right
		tween_turn.set_ease(Tween.EASE_IN)
		tween_turn.chain().tween_property(csg_box_3d, "rotation_degrees:y", -turn_dir /2, 2)
		#return
		tween_turn.set_ease(Tween.EASE_OUT_IN)
		tween_turn.chain().tween_property(csg_box_3d, "rotation_degrees:y", turn_normal_amount.y, 2)
	
		tween_bank.set_trans(Tween.TRANS_BACK)
		# turn left
		tween_bank.set_ease(Tween.EASE_OUT)
		tween_bank.tween_property(csg_box_3d, "rotation_degrees:z", bank_dir, 2)
		#turn right
		tween_bank.set_ease(Tween.EASE_IN)
		tween_bank.chain().tween_property(csg_box_3d, "rotation_degrees:z", -bank_dir /2, 2)
		#return
		tween_bank.set_ease(Tween.EASE_OUT_IN)
		tween_bank.chain().tween_property(csg_box_3d, "rotation_degrees:z", turn_normal_amount.z, 2)
	
		await tween_move.finished 
		current_lane = next_lane
		await tween_turn.finished
		moving = false
