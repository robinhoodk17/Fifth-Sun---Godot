extends CanvasItem

@onready var resume_button : Button = $TextureRect/HBoxContainer/VBoxContainer/Resume
@onready var Settings_button : Button = $TextureRect/HBoxContainer/VBoxContainer/Settings
@onready var Main_Menu_button : Button = $"TextureRect/HBoxContainer/VBoxContainer/Main Menu"
@onready var Exit_button : Button = $"TextureRect/HBoxContainer/VBoxContainer/Exit Game"
var player : int = 1
signal resumeSignal
var paused : bool = false
var button = 0
var delay : float = 0.5
var time_since_last_direction : float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("Pause_1"):
		player = 1
		swap_pause_state()
	if event.is_action_pressed("Pause_2"):
		player = 2
		swap_pause_state()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func swap_pause_state():
	if !paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		show()
		get_tree().paused = true
		paused = true
		resume_button.grab_focus()
	else:
		button = 0
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_tree().paused = false
		paused = false
		hide()
func _on_resume_button_down():
	swap_pause_state()
func _on_settings_button_down():
	pass # Replace with function body.
func _on_main_menu_button_down():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
func _on_exit_game_button_down():
	get_tree().quit()
