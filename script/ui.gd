class_name UI
extends Control

@onready var ramming_label: Control = $RammingLabel

@onready var octopus_health_bar: ProgressBar = $OctopusHealthBar/OctopusHealthBar

@onready var player_speed_bar: ProgressBar = $PlayerSpeedBar/PlayerSpeedBar
@onready var player_speed_bar_tex: TextureProgressBar = $PlayerSpeedBar/PlayerSpeedBar_tex

@onready var game_change: Panel = $GameChange
@onready var game_change_label: Label = $GameChange/GameChangeLabel

@onready var main_menu: Control = $MainMenu
@onready var main_menu_label: Label = $MainMenu/VBoxContainer/MainMenuLabel

@onready var settings_menu: Control = $Settings_menu
@onready var settings_button: Button = $MainMenu/VBoxContainer/SettingsButton
@onready var start_button: Button = $MainMenu/VBoxContainer/StartButton
@onready var v_box_container: VBoxContainer = $MainMenu/VBoxContainer

@onready var glass_rain_layer: CanvasLayer = $GlassRain_Layer

func _ready() -> void:
	Main.ui = self
	ramming_label.visible = false
	glass_rain_layer.visible = false
	game_change.visible = false
	settings_menu.visible = false
	settings_button.visible = false
	main_menu.visible = false
	octopus_health_bar.max_value = Main.octopus.max_health
	player_speed_bar.max_value = Main.wave_manager.waves[0].max_speed
	player_speed_bar_tex.max_value = Main.wave_manager.waves[0].max_speed
	
	if !Main.first_start:
		Main.go_to_main_menu()
		Main.first_start = true

func change_label(new_text) ->void:
	game_change_label.text = new_text

func _on_settings_button_pressed() -> void:
	Main.go_to_Settings_menu()
	$SfxClick.play()

func _on_start_button_pressed() -> void:
	Main.start_game()
	$SfxClick.play()
	
#SLIDERS
func _on_music_volume_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(2, db)

func _on_sfx_volume_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(1, db)

##Checkbox
func _on_mute_music_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(2,toggled_on)

func _on_mute_sfx_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(1,toggled_on)

#OPTION LIST
func _on_fullscreen_control_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_back_button_pressed() -> void:
	Main.go_to_main_menu()
	$SfxReturn.play()

##hovers
#func UI_ScaleUpTween(body: VBoxContainer, factor: float = 1.05, time: float = 0.1):
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_OUT)
	#var base_scale : Vector2 = body.scale
	#var new_scale : Vector2 = base_scale * factor
#
	#tween.tween_property(body, "scale", new_scale, time)
	#await tween.finished
#
#func UI_ScaleDownTween(body: VBoxContainer, factor: float = 1.05, time: float = 0.1):
	#var tween = get_tree().create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#var base_scale : Vector2 = body.scale
	#var new_scale : Vector2 = base_scale / factor
#
	#tween.tween_property(body, "scale", new_scale, time)
	#await tween.finished
#
#func _on_v_box_container_mouse_entered() -> void:
	#UI_ScaleUpTween(v_box_container)
#
#
#func _on_v_box_container_mouse_exited() -> void:
	#UI_ScaleDownTween(v_box_container)
