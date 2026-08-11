extends Control

@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	continue_button.pressed.connect(close_menu)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()


func open_menu() -> void:
	get_tree().paused = true
	show()
	move_to_front()
	continue_button.grab_focus()


func close_menu() -> void:
	hide()
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func _on_main_menu_pressed() -> void:
	Saves.solicitar_save("pause_main_menu")
	StudentIdentity.clear_student()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_screen.tscn")
