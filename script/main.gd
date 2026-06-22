extends Node3D

var boxes_manager : BoxesManager
var wave_manager : WaveManager
var rune_manager : RuneManager
var spawn_manager : SpawnManager
var octopus : Octupus



func _process(delta: float) -> void:
	if wave_manager && boxes_manager && boxes_manager.boxes.size() < boxes_manager.max_amount_boxes:
		Main.change_wave_for(Box)
	if wave_manager && rune_manager && rune_manager.runes.size() < rune_manager.max_runes_amount:
		Main.change_wave_for(Rune)

func slow_down(amount : int) -> void:
	wave_manager.change_speed(amount)

func speed_up(amount : int) -> void:
	wave_manager.change_speed(amount)

func change_wave_for(new_item ) -> void:	
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
	
