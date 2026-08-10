extends Control

@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	continue_button.pressed.connect(close_overlay)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()


func open_overlay() -> void:
	get_tree().paused = true
	show()
	move_to_front()
	continue_button.grab_focus()


func close_overlay() -> void:
	hide()
	get_tree().paused = false


func _on_main_menu_pressed() -> void:
	Saves.solicitar_save("jogo_concluido_menu")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_screen.tscn")

