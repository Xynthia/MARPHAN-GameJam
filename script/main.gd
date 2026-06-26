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

var tentacle_attack_timer : float = 0
var tentacle_attack_time : float = randf_range(7.0, 10.0)


func _ready() -> void:
	FadeTransition(0,2,1.3)
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
		if wave_manager && boxes_manager && boxes_manager.boxes.size() < boxes_manager.max_amount_boxes and Main.octopus.global_position == Main.octopus.starting_pos:
			Main.change_wave_for(Box)
		if wave_manager && rune_manager && rune_manager.runes.size() < rune_manager.max_runes_amount and Main.octopus.global_position == Main.octopus.starting_pos:
			Main.change_wave_for(Rune)
		
		if octopus.global_position != octopus.starting_pos:
			wave_manager.change_all_to_wave()
		else:
			tentacle_attack_timer += delta
		
		if tentacle_manager && tentacle_manager.tentacles.size() < tentacle_manager.max_tentacles && tentacle_attack_timer >= tentacle_attack_time && octopus.global_position == octopus.starting_pos:
			tentacle_manager.spawn_tentacle()
			tentacle_attack_timer = 0
			tentacle_attack_time = randf_range(7.0, 10.0)
	if !in_game and Input.is_action_just_pressed("ramming"):
		go_to_main_menu()

func start_game() -> void:
	FadeTransition(0, 1, 0)
	get_tree().change_scene_to_file("res://scenes/scene_manager.tscn")
	await get_tree().scene_changed
	get_tree().paused = false

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
	ui.game_change_label.add_theme_color_override("font_color", Color(0.82, 0.149, 0.149))
	ui.game_change.visible = true
	ui.player_speed_bar.visible = false
	ui.player_speed_bar_tex.visible = false
	ui.octopus_health_bar.visible = false
	ui.ramming_label.visible = false

func won() -> void:
	get_tree().paused = true
	in_game = false
	ui.change_label("You Won!")
	ui.game_change_label.add_theme_color_override("font_color", Color(0.016, 0.553, 0.0))
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
	

func Wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

# fades the screen to black (IN & OUT)
func FadeTransition(FADEIN_DURATION: float, FADEOUT_DURATION: float, FADEHOLD_DURATION: float) -> bool:
	var _r : bool = false

	var canvas := CanvasLayer.new()
	canvas.layer = 100
	var fade_rect := ColorRect.new()
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	canvas.add_child(fade_rect)
	add_child(canvas)
	var fade_out := create_tween()
	fade_out.tween_property(fade_rect, "color:a", 1.0, (FADEIN_DURATION))
	await fade_out.finished

	await Wait(FADEIN_DURATION)
	
	await Wait(FADEHOLD_DURATION)

	var fade_in := create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, (FADEOUT_DURATION))
	await fade_in.finished

	canvas.queue_free()
	_r = true
	
	return _r
