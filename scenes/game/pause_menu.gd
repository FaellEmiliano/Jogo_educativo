extends Control

@onready var continue_button: Button = %ContinueButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	continue_button.pressed.connect(close_menu)
	exit_button.pressed.connect(_on_exit_pressed)
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


func _on_exit_pressed() -> void:
	Saves.solicitar_save("pause_exit")
	get_tree().paused = false
	get_tree().quit()
