class_name UI
extends Control

@onready var ramming_label: Control = $RammingLabel

@onready var octopus_health_bar: ProgressBar = $OctopusHealthBar/OctopusHealthBar

@onready var player_speed_bar: ProgressBar = $PlayerSpeedBar/PlayerSpeedBar

@onready var game_change: Panel = $GameChange
@onready var game_change_label: Label = $GameChange/GameChangeLabel

@onready var main_menu: Control = $MainMenu
@onready var main_menu_label: Label = $MainMenu/MainMenuLabel

@onready var settings_menu: Control = $Settings_menu
@onready var settings_button: Button = $Settings_button


func _ready() -> void:
	Main.ui = self
	ramming_label.visible = false
	game_change.visible = false
	settings_menu.visible = false
	settings_button.visible = false
	main_menu.visible = false
	octopus_health_bar.max_value = Main.octopus.max_health
	player_speed_bar.max_value = Main.wave_manager.waves[0].max_speed
	Main.player.camera_3d.current = false
	
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
