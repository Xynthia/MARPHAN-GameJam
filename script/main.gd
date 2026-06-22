extends Node3D

var boxes_manager : BoxesManager
var wave_manager : WaveManager
var rune_manager : RuneManager
var spawn_manager : SpawnManager

func _process(delta: float) -> void:
	if wave_manager && boxes_manager && boxes_manager.boxes.size() < boxes_manager.max_amount_boxes:
		Main.change_wave_for(Box)
	if wave_manager && rune_manager && rune_manager.runes.size() < rune_manager.max_runes_amount:
		Main.change_wave_for(Rune)

func slow_down() -> void:
	match wave_manager.current_speed:
		wave_manager.speeds.NORMAL:
			wave_manager.change_speed(wave_manager.speeds.SLOW)
		wave_manager.speeds.FAST:
			wave_manager.change_speed(wave_manager.speeds.NORMAL)

func speed_up() -> void:
	match wave_manager.current_speed:
		wave_manager.speeds.SLOW:
			wave_manager.change_speed(wave_manager.speeds.NORMAL)
		wave_manager.speeds.NORMAL:
			wave_manager.change_speed(wave_manager.speeds.FAST)

func change_wave_for(new_item ) -> void:
	var random_path_id : int = randi_range(1, 3)
	var random_path : Path3D
	match random_path_id:
		1:
			random_path = wave_manager.path_1
		2:
			random_path = wave_manager.path_2
		3:
			random_path = wave_manager.path_3
	
	var random_wave : Wave = spawn_manager.waves.pick_random()
	var random_follow_path : PathFollow3D = random_wave.parent
	while random_follow_path.get_child_count() > 1:
		random_wave= spawn_manager.waves.pick_random()
		random_follow_path = random_wave.parent
	
	wave_manager.hide_wave(random_follow_path)
	match new_item:
		Rune:
			rune_manager.spawn_rune(random_follow_path)
		Box:
			boxes_manager.spawn_box(random_follow_path)
	
