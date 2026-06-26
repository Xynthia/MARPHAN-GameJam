extends Node3D

var boxes_manager : BoxesManager
var wave_manager : WaveManager
var rune_manager : RuneManager
var tentacle_manager : TentacleManager
var spawn_manager : SpawnManager
var octopus : Octupus
var ui : UI
var player: Player
var game : Game

var in_game : bool = false
var first_start : bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

var ramming_speed : bool = false:
	set(value):
		ramming_speed = value
		if ramming_speed == true:
			octopus.move_to_middle()
		elif ui:
			ui.ramming_label.visible = false
			octopus.move_to_start()

func _process(delta: float) -> void:
	if in_game:
		if wave_manager && boxes_manager && boxes_manager.boxes.size() < boxes_manager.max_amount_boxes:
			Main.change_wave_for(Box)
		if wave_manager && rune_manager && rune_manager.runes.size() < rune_manager.max_runes_amount:
			Main.change_wave_for(Rune)
		
		if tentacle_manager && tentacle_manager.tentacles.size() < tentacle_manager.max_tentacles:
			pass
	if !in_game and Input.is_action_just_pressed("ramming"):
		go_to_main_menu()

func start_game() -> void:
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://scenes/scene_manager.tscn")
	await get_tree().scene_changed
	ui.glass_rain_layer.visible = true
	game.visible = true

func go_to_Settings_menu() -> void:
	ui.settings_menu.visible = true
	
	game.visible = false
	ui.main_menu.visible = false
	ui.settings_button.visible = false
	ui.game_change.visible = false
	ui.player_speed_bar.visible = false
	ui.player_speed_bar_tex.visible = false
	ui.octopus_health_bar.visible = false
	ui.ramming_label.visible = false

func go_to_main_menu()-> void:
	get_tree().paused = true
	
	ui.main_menu.visible = true
	ui.settings_button.visible = true
	ui.glass_rain_layer.visible = false
	game.visible = false
	ui.settings_menu.visible = false
	ui.game_change.visible = false
	ui.player_speed_bar.visible = false
	ui.player_speed_bar_tex.visible = false
	ui.octopus_health_bar.visible = false
	ui.ramming_label.visible = false
	

func die() -> void:
	get_tree().paused = true
	in_game = false
	ui.change_label("You Died!")
	ui.game_change.visible = true
	ui.player_speed_bar.visible = false
	ui.player_speed_bar_tex.visible = false
	ui.octopus_health_bar.visible = false
	ui.ramming_label.visible = false

func won() -> void:
	get_tree().paused = true
	in_game = false
	ui.change_label("You Won!")
	ui.game_change.visible = true
	ui.player_speed_bar.visible = false
	ui.player_speed_bar_tex.visible = false
	ui.octopus_health_bar.visible = false
	ui.ramming_label.visible = false

func slow_down(amount : float) -> void:
	wave_manager.change_speed(amount)

func speed_up(amount : float) -> void:
	wave_manager.change_speed(amount)

func change_wave_for(new_item ) -> void:
	if spawn_manager.waves:
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
			Tentacle:
				tentacle_manager.spawn_tentacle(random_follow_path)
	
