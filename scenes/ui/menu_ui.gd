class_name MenuUI
extends CanvasLayer

enum MenuStates{
	NONE,
	MAIN_MENU,
	SETTINGS_MENU,
	PAUSE_MENU,
	DEATH_MENU,
}

var curr_menu_state: MenuStates = MenuStates.MAIN_MENU
var is_start_menu := true

@export_file("*.tscn") var load_scene: String
@export_group("Node References")
# main menu buttons
@export_subgroup("Main Menu")
@export var main_menu: VBoxContainer
@export var mm_play_button: Button
@export var mm_settings_button: Button
@export var mm_quit_button: Button
# pause menu buttons
@export_subgroup("Pause Menu")
@export var pause_menu: VBoxContainer
@export var pm_resume_button: Button
@export var pm_settings_button: Button
@export var pm_quit_button: Button
# settings menu buttons
@export_subgroup("Settings Menu")
@export var settings_menu: VBoxContainer
@export var back_button: Button
# settings menu sliders
@export var master_volume_slider: HSlider
@export var music_volume_slider: HSlider
@export var sound_effect_volume_slider: HSlider
@export_subgroup("Death Menu")
# death menu
@export var death_menu: VBoxContainer
@export var dm_retry_button: Button
@export var dm_quit_button: Button

@onready var background: TextureRect = $Background

@onready var btn_to_func: Dictionary[Button, Callable] = {
	# main menu
	mm_play_button : _on_play_button_pressed,
	mm_settings_button : _on_settings_button_pressed,
	mm_quit_button : _on_quit_button_pressed,
	# pause menu
	pm_resume_button : _on_resume_button_pressed,
	pm_settings_button : _on_settings_button_pressed,
	pm_quit_button : _on_quit_button_pressed,
	# settings menu
	back_button: _on_back_button_pressed,
	# death menu
	dm_retry_button : _on_play_button_pressed,
	dm_quit_button : _on_quit_button_pressed,
} 

@onready var slider_value_changed_to_func: Dictionary[Slider, Callable] = {
	master_volume_slider: _on_master_slider_value_changed,
	music_volume_slider: _on_music_slider_value_changed,
	sound_effect_volume_slider: _on_sfx_slider_value_changed,
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for btn in btn_to_func:
		if btn:
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
	visible = true
	if background:
		background.visible = is_start_menu
	
	curr_menu_state = state
	
	if state == MenuStates.DEATH_MENU:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if dm_retry_button:
			dm_retry_button.grab_focus()
	
	match state:
		MenuStates.NONE:
			# Hide just the sub-menus or the entire layer depending on design.
			# If we want the layer hidden: visible = false (but let's keep it visible for now and just hide contents)
			main_menu.visible = false
			pause_menu.visible = false
			settings_menu.visible = false
			death_menu.visible = false
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED
			pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
			death_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.MAIN_MENU:
			main_menu.visible = true
			pause_menu.visible = false
			settings_menu.visible = false
			death_menu.visible = false
			main_menu.process_mode = Node.PROCESS_MODE_INHERIT
			pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
			death_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.PAUSE_MENU:
			main_menu.visible = false
			pause_menu.visible = true
			settings_menu.visible = false
			death_menu.visible = false
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED
			pause_menu.process_mode = Node.PROCESS_MODE_INHERIT
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
			death_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.SETTINGS_MENU:
			main_menu.visible = false
			pause_menu.visible = false
			settings_menu.visible = true
			death_menu.visible = false
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED
			pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
			settings_menu.process_mode = Node.PROCESS_MODE_INHERIT
			death_menu.process_mode = Node.PROCESS_MODE_DISABLED
		MenuStates.DEATH_MENU:
			main_menu.visible = false
			pause_menu.visible = false
			settings_menu.visible = false
			death_menu.visible = true
			main_menu.process_mode = Node.PROCESS_MODE_DISABLED
			pause_menu.process_mode = Node.PROCESS_MODE_DISABLED
			settings_menu.process_mode = Node.PROCESS_MODE_DISABLED
			death_menu.process_mode = Node.PROCESS_MODE_INHERIT


func _on_play_button_pressed() -> void:
	get_tree().paused = false
	if is_start_menu:
		if load_scene:
			print("Changing scene to: ", load_scene)
			get_tree().change_scene_to_file(load_scene)
		else:
			print("Error: load_scene path is empty!")
	else:
		print("Reloading current scene")
		get_tree().reload_current_scene()


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
