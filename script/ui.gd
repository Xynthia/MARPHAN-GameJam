class_name UI
extends Control

@onready var ramming_label: Control = $RammingLabel

@onready var octopus_health_bar: ProgressBar = $OctopusHealthBar/OctopusHealthBar

@onready var player_speed_bar: ProgressBar = $PlayerSpeedBar/PlayerSpeedBar

@onready var game_change: Panel = $GameChange
@onready var game_change_label: Label = $GameChange/GameChangeLabel

@onready var main_menu: Control = $MainMenu
@onready var main_menu_label: Label = $MainMenu/MainMenuLabel


func _ready() -> void:
	Main.ui = self
	ramming_label.visible = false
	game_change.visible = false
	main_menu.visible = false
	octopus_health_bar.max_value = Main.octopus.max_health
	player_speed_bar.max_value = Main.wave_manager.waves[0].max_speed
	
	if !Main.first_start:
		Main.go_to_main_menu()
		Main.first_start = true

func change_label(new_text) ->void:
	game_change_label.text = new_text


func _on_start_button_pressed() -> void:
	Main.start_game()
