extends Control
var context
@onready var code_edit: CodeEdit = $Panel/VBoxContainer/EditorFrame/CodeEdit
@onready var status_label: Label = $Panel/VBoxContainer/Header/StatusLabel
@onready var run_button: Button = $Panel/VBoxContainer/Header/Run
@onready var stop_button: Button = $Panel/VBoxContainer/Header/Stop
var running = false


func _ready() -> void:
	EventBus.update_context.connect(context_updt)
	context = GameManager.current_context
	_update_status(false)

func _on_fechar_pressed() -> void:
	get_window().hide()

func _on_minimizar_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().size.y = 37
	else:
		get_window().size.y = 252


func _on_run_pressed() -> void:
	if not running:
		running = true
		InterpreterSystem.execute(code_edit.text,context)
		code_edit.release_focus()
		_update_status(true)
		running = false


func _on_stop_pressed() -> void:
	InterpreterSystem.stop()
	_update_status(false)

func context_updt(ctx):
	context = ctx.env_context


func _update_status(is_active: bool) -> void:
	if is_active:
		status_label.text = "RODANDO"
		status_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.55))
		run_button.disabled = true
		stop_button.disabled = false
	else:
		status_label.text = "PARADO"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
		run_button.disabled = false
		stop_button.disabled = true
