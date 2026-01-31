class_name MenuUI
extends CanvasLayer

enum MenuStates{
	NONE,
	MAIN_MENU,
	SETTINGS_MENU,
	PAUSE_MENU,
}

var curr_menu_state: MenuStates = MenuStates.MAIN_MENU
var is_start_menu := true

@export_file("*.tscn") var load_scene: String
@export_group("Node References")
@export var main_menu: VBoxContainer
@export var settings_menu: VBoxContainer
# main menu buttons
@export var play_button: Button
@export var resume_button: Button
@export var settings_button: Button
@export var quit_button: Button
# settings menu buttons
@export var back_button: Button
# settings menu sliders
@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var sound_effect_volume_slider: HSlider

@onready var btn_to_func: Dictionary[Button, Callable] = {
	play_button : _on_play_button_pressed,
	resume_button : _on_resume_button_pressed,
	settings_button : _on_settings_button_pressed,
	quit_button : _on_quit_button_pressed,
	back_button: _on_back_button_pressed
} 

@onready var slider_value_changed_to_func: Dictionary[Slider, Callable] = {
	master_volume_slider: _on_master_slider_value_changed,
	music_volume_slider: _on_music_slider_value_changed,
	sound_effect_volume_slider: _on_sfx_slider_value_changed,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for btn in btn_to_func:
		btn.pressed.connect(btn_to_func[btn])
	for slider in slider_value_changed_to_func:
		slider.value_changed.connect(slider_value_changed_to_func[slider])
	set_menu_state(curr_menu_state)
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		Globals.master_volume
	)
	master_volume_slider.value = Globals.master_volume
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Music"),
		Globals.music_volume
	)
	music_volume_slider.value = Globals.music_volume
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("SoundEffects"),
		Globals.sfx_volume
	)
	sound_effect_volume_slider.value = Globals.sfx_volume


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PauseEscape"):
		match curr_menu_state:
			MenuStates.PAUSE_MENU:
				if get_tree().paused:
					_unpause()
				else:
					_pause()
			MenuStates.SETTINGS_MENU:
				if is_start_menu:
					set_menu_state(MenuStates.MAIN_MENU)
				else:
					set_menu_state(MenuStates.PAUSE_MENU)
			MenuStates.NONE:
				_pause()
				set_menu_state(MenuStates.PAUSE_MENU)


func _unpause() -> void:
	get_tree().paused = false
	set_menu_state(MenuStates.NONE)


func _pause() -> void:
	get_tree().paused = true
	set_menu_state(MenuStates.PAUSE_MENU)


func set_menu_state(state: MenuStates) -> void:
	print("Set Menu State to: ", state)
	curr_menu_state = state
	match state:
		MenuStates.NONE:
			# main
			main_menu.visible = false
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED
			# settings
			settings_menu.visible = false
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.MAIN_MENU:
			# main
			main_menu.visible = true
			play_button.visible = true
			resume_button.visible = false
			play_button.process_mode = Node.PROCESS_MODE_INHERIT
			resume_button.process_mode = Node.PROCESS_MODE_DISABLED
			main_menu.process_mode = Node.PROCESS_MODE_INHERIT
			# settings
			settings_menu.visible = false
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.PAUSE_MENU:
			# main
			main_menu.visible = true
			play_button.visible = false
			resume_button.visible = true
			play_button.process_mode = Node.PROCESS_MODE_DISABLED
			resume_button.process_mode = Node.PROCESS_MODE_INHERIT
			main_menu.process_mode = Node.PROCESS_MODE_INHERIT
			# settings
			settings_menu.visible = false
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.SETTINGS_MENU:
			# main
			main_menu.visible = false
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED
			# settings
			settings_menu.visible = true
			settings_menu.process_mode = Node.PROCESS_MODE_INHERIT


func _on_play_button_pressed() -> void:
	if load_scene:
		get_tree().change_scene_to_file(load_scene)


func _on_resume_button_pressed() -> void:
	_unpause()
	set_menu_state(MenuStates.NONE)


func _on_settings_button_pressed() -> void:
	set_menu_state(MenuStates.SETTINGS_MENU)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	if is_start_menu:
		set_menu_state(MenuStates.MAIN_MENU)
	else:
		set_menu_state(MenuStates.PAUSE_MENU)


func _on_master_slider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		new_value
	)
	Globals.master_volume = new_value


func _on_music_slider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Music"),
		new_value
	)
	Globals.music_volume = new_value


func _on_sfx_slider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("SoundEffects"),
		new_value
	)
	Globals.sfx_volume = new_value


# *******************************
